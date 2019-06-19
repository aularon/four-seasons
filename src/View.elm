module View exposing (view)

import Array
import Browser exposing (Document)
import Color exposing (Color)
import Common exposing (InfoState(..), Model, MouseMovement, Msg(..))
import Date exposing (Date)
import FourSeasons exposing (assyrianMonths, movements, seasons, sonnets, spring)
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
        effectiveTime =
            if model.seekerMouseIsDown then
                model.seekTime

            else
                model.currentTime

        currentMovement =
            Movement.currentFromTime effectiveTime

        currentSeason =
            seasons |> Array.get (currentMovement.index // 3) |> Maybe.withDefault spring

        sonnet =
            sonnets |> Array.get currentMovement.index |> Maybe.withDefault [ [] ]

        currentPosix =
            Utils.timeToPosix effectiveTime

        currentDate =
            Date.fromPosix utc currentPosix

        currentProgress =
            Utils.timeToProgress model.equalizeSizes effectiveTime

        hue =
            Utils.timeToHue effectiveTime

        color =
            Color.hsl (hue / 360) 0.5 0.7

        hex =
            Color.hsl (hue / 360) 0.7 0.5 |> colorToHex

        dateStr =
            Date.format "MMMM ddd" currentDate

        assyrianMonth =
            assyrianMonths |> Array.get currentMovement.index |> Maybe.withDefault ""

        --_ =
        --    Debug.log "style" (style "background" (Utils.color hue 50 70))
    in
    Document "Four Seasons"
        [ div
            [ class "container"
            , classList
                [ ( "playing", model.isPlaying )
                , ( "start", model.infoState == Start )
                , ( "show-info", model.infoState /= Hidden )
                ]
            , style "background" (Color.toCssString color)
            ]
            [ audio
                [ Html.Attributes.id "player"
                , controls True
                , Html.Attributes.loop True
                , onTimeUpdate TimeUpdate
                , on "play" (Json.succeed Play)
                , on "pause" (Json.succeed Pause)
                ]
                [ Html.source [ src "/four-seasons.ogg", type_ "audio/ogg" ] []
                , Html.source [ src "/four-seasons.m4a", type_ "audio/mp4" ] []
                , Html.source [ src "/four-seasons.mp3", type_ "audio/mpeg" ] []
                ]

            --, debugInfo model
            , div
                [ class "main"
                ]
                [ Html.h2 [] [ text "Current Movement" ]
                , div [ class "label" ]
                    [ text (currentSeason.name ++ " #" ++ (currentMovement.index |> modBy 3 |> (+) 1 |> String.fromInt))
                    ]
                , Html.h2 [] [ text "Matching Date/Time" ]
                , div [ class "date" ]
                    [ span [] [ text (dateStr |> String.dropRight 2) ]
                    , Html.sup [] [ text (dateStr |> String.right 2) ]
                    ]
                , div [ class "time" ] [ text (Utils.formatTime currentPosix) ]

                --, div [ class "hint" ] [ text "click to play" ]
                --, div [] [ text "la sonata" ]
                --, div [] [ text "deine colore" ]
                , Html.h2 [] [ text "Sonnet" ]
                , div [ class "sonnet" ] (sonnet |> List.map (\p -> sonnetP p))
                , Html.h2 [] [ text "Trivia" ]
                , div
                    [ class "color" ]
                    [ div [] [ text "Corresponding Assyrian Month:" ]
                    , Html.strong
                        []
                        [ text ("Month of " ++ assyrianMonth) ]
                    ]

                --, div [] [ text " (click to copy!)" ]
                , div
                    [ class "color" ]
                    [ div [] [ text "Day's color:" ]
                    , div
                        [ style "color" ("#" ++ hex), class "hex" ]
                        [ text ("#" ++ hex |> String.toUpper) ]

                    --, div [] [ text " (click to copy!)" ]
                    ]
                ]
            , div
                [ class "playpause"
                , classList [ ( "paused", model.isPlaying ) ]
                , Html.Events.onClick
                    (ExternalAction
                        (if model.isPlaying then
                            "pause"

                         else
                            "play"
                        )
                    )
                ]
                []
            , div
                [ class "info-button"
                , Html.Events.onClick ToggleInfo
                ]
                [ text "?" ]

            --, div
            --    [ class "share"
            --    , Html.Events.onClick (ExternalAction "share")
            --    ]
            --    [ text "share!" ]
            , div
                [ class "info", Html.Events.onClick ToggleInfo ]
                [ Html.h1 [] [ text "Vivaldi's Four Seasons" ]
                , Html.em []
                    [ text
                        (if model.infoState == Start then
                            "Click to start!"

                         else
                            "Click to get back!"
                        )
                    ]
                , Html.hr [] []
                , div [ class "ps" ]
                    [ Html.p [] [ text "Across the Four Seasons: An exploration into Vivaldi's Four Seasons concerti" ]
                    , Html.p [] [ text "The Four Seasons is a group of four violin concerti, each of which gives musical expression to a season of the year. Vivaldi separated each concerto into three movements, which gives us a total of 12 movements." ]
                    , Html.p [] [ text "I mapped every month to a movement, giving it its own color. Spring months were given shades of green, yellows for Summer, reds for Autumn and blues for Winter.\nThis resulted in each day of the year having its own little piece of music within its month's movement. The same way we get a color that corresponds to each and every day!" ]
                    , Html.p [] [ text "Finally, I matched the movements with Assyrian months (Not sure about their trustworthiness, but I like the descriptions!), and of course: The corresponding sonnetes that accompany each of the 12 movements." ]
                    ]
                , Html.hr [] []
                , Html.div [ style "font-weight" "bold" ] [ text "Hope you enjoy it!" ]
                , Html.em []
                    [ text
                        (if model.infoState == Start then
                            "You can click anywhere, anytime to start!"

                         else
                            "Click anywhere to get back!"
                        )
                    ]
                , Html.hr [] []
                , Html.div []
                    [ text "This exploration is built using "
                    , Html.a
                        [ Html.Attributes.href "https://elm-lang.org/", Html.Attributes.target "_blank" ]
                        [ text "Elm" ]
                    , text ". You can browse the source code here: "
                    , Html.a
                        [ Html.Attributes.href "https://github.com/aularon/four-seasons", Html.Attributes.target "_blank" ]
                        [ text "https://github.com/aularon/four-seasons" ]
                    ]

                --, div [ class "settings" ]
                --    [ Html.label []
                --        [ Html.input [ type_ "checkbox", Html.Attributes.checked model.equalizeSizes, Html.Events.onClick ToggleSizing ] []
                --        , text "Equalize Sizes?"
                --        ]
                --    ]
                ]
            , div
                [ class "seeker"

                --, debugMouseMove MouseMove
                , onSeek "mousemove"
                , onSeek "touchmove"
                , onSeek "mouseup"
                , on "mousedown" (Json.succeed SeekerMouseDown)
                , on "touchend" (Json.succeed SeekerMouseUp)
                ]
                [ Html.ul
                    [ class "movements"
                    ]
                    (Array.toList (Array.map (\m -> movementToLi m model) movements))
                , Html.ul
                    [ class "seasons"
                    ]
                    (seasons |> Array.map (seasonToLi model) |> Array.toList)
                , div
                    [ class "cursor"
                    , style "left" (String.fromFloat currentProgress ++ "%")
                    , style "border-color" (Color.hsl (hue / 360) 0.9 0.2 |> Color.toCssString)
                    ]
                    []
                , div [ class "progress", style "width" (String.fromFloat (100 - currentProgress) ++ "%") ] []
                ]
            ]
        ]


sonnetP p =
    Html.p [] (List.concatMap (\l -> [ text l, Html.br [] [] ]) p)


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
