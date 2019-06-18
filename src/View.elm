module View exposing (view)

import Array
import Browser exposing (Document)
import Color exposing (Color)
import Common exposing (Model, MouseMovement, Msg(..))
import Date exposing (Date)
import FourSeasons exposing (movements, seasons)
import FourSeasons.Utils as Utils
import Hex
import Html exposing (Attribute, Html, audio, div, li, pre, span, text, ul)
import Html.Attributes exposing (class, classList, controls, src, style, type_)
import Html.Events exposing (on)
import Json.Decode as Json
import Music exposing (Movement)
import Music.Movement as Movement
import Time exposing (utc)



-- VIEW


colorToHex : Color -> String
colorToHex color =
    let
        rgba =
            Color.toRgba color

        hex =
            [ rgba.red, rgba.green, rgba.blue ]
                |> List.map (\x -> x * 256 |> round |> Hex.toString |> String.padLeft 2 '0')
                |> String.join ""
    in
    hex


view : Model -> Document Msg
view model =
    let
        currentMovement =
            Movement.currentFromTime model.currentTime

        currentPosix =
            Utils.timeToPosix model.currentTime

        currentDate =
            Date.fromPosix utc currentPosix

        currentProgress =
            Utils.timeToProgress model.equalizeSizes model.currentTime

        hue =
            Utils.timeToHue model.currentTime

        color =
            Color.hsl (hue / 360) 0.5 0.7

        hex =
            Color.hsl (hue / 360) 0.7 0.5 |> colorToHex

        --_ =
        --    Debug.log "style" (style "background" (Utils.color hue 50 70))
    in
    Document "Four Seasons"
        [ div
            [ class "container"
            , classList [ ( "playing", model.isPlaying ) ]
            , style "background" (Color.toCssString color)
            ]
            [ audio
                [ Html.Attributes.id "player"
                , src "/four-seasons.mp3"
                , controls True
                , onTimeUpdate TimeUpdate
                , on "play" (Json.succeed Play)
                , on "pause" (Json.succeed Pause)
                ]
                []

            --, debugInfo model
            , div
                [ Html.Events.onClick PlayPause
                , class "main"
                ]
                [ div [ class "date" ] [ text (Date.format "MMMM ddd" currentDate) ]
                , div [ class "time" ] [ text (Utils.formatTime currentPosix) ]
                , div
                    [ class "color" ]
                    [ div [] [ text "your color is " ]
                    , div
                        [ style "color" ("#" ++ hex), class "hex" ]
                        [ text ("#" ++ hex |> String.toUpper) ]
                    , div [] [ text " (click to copy!)" ]
                    ]
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
                , div [ class "cursor", style "left" (String.fromFloat currentProgress ++ "%") ] []
                , div [ class "progress", style "width" (String.fromFloat (100 - currentProgress) ++ "%") ] []
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
        , style "background" (Color.toCssString (Color.hsl (s.hue / 360) 0.7 0.4))
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
        , style "background" (Utils.movementColor m 0.7 0.4 |> Color.toCssString)
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
