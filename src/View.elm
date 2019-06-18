module View exposing (view)

import Array
import Browser exposing (Document)
import Common exposing (Model, MouseMovement, Msg(..))
import Date exposing (Date)
import FourSeasons exposing (movements, seasons)
import FourSeasons.Utils as Utils
import Html exposing (Attribute, Html, audio, div, li, pre, text, ul)
import Html.Attributes exposing (class, classList, controls, src, style, type_)
import Html.Events exposing (on)
import Json.Decode as Json
import Music exposing (Movement)
import Music.Movement as Movement
import Time exposing (utc)



-- VIEW


view : Model -> Document Msg
view model =
    let
        currentMovement =
            Movement.currentFromTime model.currentTime

        currentPosix =
            Utils.timeToPosix model.currentTime
    in
    Document "Four Seasons"
        [ div
            [ class "container"
            , classList [ ( "playing", model.isPlaying ) ]
            , style "background" (Utils.color (Utils.timeToHue model.currentTime) 50 70)
            ]
            [ audio
                [ Html.Attributes.id "player"
                , src "./four-seasons.mp3"
                , controls True
                , onTimeUpdate TimeUpdate
                , on "play" (Json.succeed Play)
                , on "pause" (Json.succeed Pause)
                ]
                []

            --, debugInfo model
            , div
                [ Html.Events.onClick PlayPause
                ]
                [ div [ class "date" ] [ text (Date.format "MMMM ddd" (Date.fromPosix utc currentPosix)) ]
                , div [ class "hint" ] [ text "click to play" ]

                --, div [] [ text "la sonata" ]
                --, div [] [ text "deine colore" ]
                ]
            , div
                [ class "seeker"

                --, debugMouseMove MouseMove
                , onSeek "mousemove"
                , onSeek "touchmove"
                , onSeek "mouseup"
                , on "mousedown" (Json.succeed SeekerMouseDown)
                ]
                [ Html.ul
                    [ class "movements"
                    ]
                    (Array.toList (Array.map (\m -> movementToLi m model) movements))
                , Html.ul
                    [ class "seasons"
                    ]
                    (seasons |> Array.map (seasonToLi model) |> Array.toList)
                , div [ class "cursor", style "left" (String.fromFloat (Utils.timeToProgress model.equalizeSizes model.currentTime) ++ "%") ] []
                ]
            , Html.label []
                [ Html.input [ type_ "checkbox", Html.Attributes.checked model.equalizeSizes, Html.Events.onClick ToggleSizing ] []
                , text "Equalize Sizes?"
                ]
            ]
        ]


seasonToLi model s =
    let
        width =
            s.movements
                |> Array.slice 0 3
                |> Array.map (Movement.percentWidth model.equalizeSizes)
                |> Array.foldr (+) 0
    in
    li
        [ style "width"
            (String.fromFloat width ++ "%")
        , style "background" (Utils.color s.hue 70 40)
        ]
        [ text s.name ]



-- view helper, gets a listing LI from movement


movementToLi : Movement -> Model -> Html msg
movementToLi m model =
    let
        currentMovement =
            Movement.currentFromTime model.currentTime

        width =
            Movement.percentWidth model.equalizeSizes m
    in
    li
        [ classList [ ( "active", m == currentMovement ) ]
        , style "background" (Utils.movementColor m 70 40)
        , style "width" (String.fromFloat width ++ "%")
        ]
        [ div [ class "tempo" ] [ text m.tempo ]
        , div [ class "scale" ] [ text m.scale ]
        ]



-- Event Handlers


onSeek : String -> Html.Attribute Msg
onSeek eventName =
    case eventName of
        "touchmove" ->
            on eventName (Json.map MouseMove (mouseMoveDecoder [ "touches", "0", "clientX" ]))

        _ ->
            on eventName (Json.map MouseMove (mouseMoveDecoder [ "clientX" ]))



-- Custom event handler
-- Used in the view to handle the audio's `timeupdate`


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)


targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float


mouseMoveDecoder : List String -> Json.Decoder MouseMovement
mouseMoveDecoder xPath =
    Json.map3 MouseMovement
        (Json.at [ "type" ] Json.string)
        (Json.at xPath Json.float)
        (Json.at [ "currentTarget", "offsetWidth" ] Json.float)



-- This one gets us a nice debug div
--debugInfo model =
--    let
--        currentMovement =
--            Movement.currentFromTime model.currentTime
--        currentPosix =
--            Utils.timeToPosix model.currentTime
--    in
--    pre []
--        [ text
--            (Date.format "MMMM ddd, y" (Date.fromPosix utc currentPosix)
--                ++ " "
--                ++ Utils.formatTime currentPosix
--                ++ "\nPrev: "
--                --++ "\n"
--                ++ Debug.toString (Movement.prev currentMovement)
--                ++ " ends @"
--                ++ (currentMovement
--                        |> Movement.prev
--                        |> Movement.ends
--                        |> Debug.toString
--                   )
--                ++ "\nCurrent: "
--                ++ Debug.toString currentMovement
--                ++ " ends @"
--                ++ (currentMovement
--                        |> Movement.ends
--                        |> Debug.toString
--                   )
--                ++ "\nNext: "
--                --++ "\n"
--                ++ Debug.toString (Movement.next currentMovement)
--                ++ " ends @"
--                ++ (currentMovement
--                        |> Movement.next
--                        |> Movement.ends
--                        |> Debug.toString
--                   )
--                ++ "\nRemaining: "
--                ++ Debug.toString (Movement.remaininigTillNext model.currentTime)
--                ++ "\nDate: "
--                ++ Date.format "MMMM ddd, y" (Utils.startDate currentMovement)
--                --++ Debug.toString (Utils.startDate currentMovement)
--                ++ "\nCurrent Time: "
--                ++ Debug.toString model.currentTime
--                ++ "\n"
--                --++ Debug.toString (model.movements |> List.reverse |> List.head)
--                ++ "\n"
--                ++ .label currentMovement
--                ++ "\n"
--                ++ (model.currentTime
--                        |> Debug.toString
--                   )
--                ++ "\n"
--                ++ (model.currentTime
--                        |> Utils.timeToHue
--                        |> Debug.toString
--                   )
--            )
--        --(toString (Utils.timeToDate model.currentTime)
--        --)
--        ]
--debugMouseMove : (Float -> msg) -> Attribute msg
--debugMouseMove msg =
--    let
--        _ =
--            Debug.log "any" (J.encode 2 (msg 1))
--    in
--    on "mousemove" (Json.map msg (Json.at [ "target", "pageX" ] Json.float))
--onClickNoBubble : Html.Attribute msg
--onClickNoBubble =
--    Html.Events.on "click" (Json.succeed { message = MouseMove, stopPropagation = True, preventDefault = True })
--onClick : msg -> Attribute msg
--onClick message =
--onTimeUpdate : (Float -> msg) -> Attribute msg
--onTimeUpdate msg =
--    on "timeupdate" (Json.map msg targetCurrentTime)
-- our main view div
