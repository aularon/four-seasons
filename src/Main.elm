port module FourSeasonsApp exposing (main)

--import Date exposing (Date)

import Array
import Browser
import Browser.Events
import Date exposing (Date)
import FourSeasons exposing (..)
import FourSeasons.Utils as Utils
import Html exposing (Attribute, Html, audio, div, li, pre, text, ul)
import Html.Attributes exposing (class, classList, controls, src, style, type_)
import Html.Events exposing (on)
import Json.Decode as Json
import Json.Encode
import Music exposing (Movement)
import Music.Movement as Movement
import Time exposing (utc)



-- Main


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { currentTime : Float
    , equalizeSizes : Bool
    , title : String
    , seekerMouseIsDown : Bool
    }



-- MSG
-- Different type of messages we get to our update function


type Msg
    = NoOp
    | ExampleSimpleMessage
    | TimeUpdate Float
    | MouseMove MouseMovement
    | SetTime Float
    | ToggleSizing
    | SeekerMouseDown
    | SeekerMouseUp



-- Custom event handler
-- Used in the view to handle the audio's `timeupdate`


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)


targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float



-- 100% split among the 12 movements
-- This one takes current progress as input (along current equalizeSizes flag) and emits a SetTime Msg
-- Used in the range input (slider) onInput handler


setProgress : Bool -> String -> Msg
setProgress equalizeSizes input =
    SetTime (progressToTime equalizeSizes (Maybe.withDefault 0 (String.toFloat input)))



-- convert current % progress to a timestamp


progressToTime : Bool -> Float -> Float
progressToTime equalizeSizes progress =
    case equalizeSizes of
        True ->
            distortedProgressToTime progress

        False ->
            progress * fullLength / 100



-- The distorted extension of the one above


distortedProgressToTime : Float -> Float
distortedProgressToTime progress =
    let
        movementNumber =
            floor (progress / percentLength)

        movement =
            case Array.get movementNumber movements of
                Nothing ->
                    defaultMovement

                Just m ->
                    m

        relativeProgress =
            (progress - (toFloat movementNumber * percentLength)) * 12.0

        relativeTime =
            movement.length * (relativeProgress / 100)

        adjustedTime =
            movement.start + relativeTime

        --_ = Debug.log "movementNumber" (movementNumber, movement, relativeProgress)
        --movementNumber =
    in
    adjustedTime



-- now this one is used to set current value of the slider (input range control)
-- it depends on current time, and respects equalizeSizes flag


timeToProgress : Bool -> Float -> Float
timeToProgress equalizeSizes time =
    case equalizeSizes of
        True ->
            timeToDistortedProgress time

        False ->
            time * 100 / fullLength



-- The distorted extension of the one above


timeToDistortedProgress : Float -> Float
timeToDistortedProgress time =
    let
        currentMovement =
            Movement.currentFromTime time

        baseProgress =
            toFloat currentMovement.index * percentLength

        extraProgress =
            (time - currentMovement.start) * percentLength / currentMovement.length

        --_ =
        --    Debug.log "debug 77:" ( baseProgress, extraProgress )
    in
    baseProgress + extraProgress



-- PORT
-- this is subscribed to from javascript side


port setCurrentTime : Float -> Cmd msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- The audio is playing and we get an update
        TimeUpdate time ->
            ( { model | currentTime = time }, Cmd.none )

        -- The user seeks to a new timing
        SetTime newTime ->
            ( model, setCurrentTime newTime )

        ToggleSizing ->
            ( { model | equalizeSizes = not model.equalizeSizes }, Cmd.none )

        SeekerMouseDown ->
            ( { model | seekerMouseIsDown = True }, Cmd.none )

        SeekerMouseUp ->
            ( { model | seekerMouseIsDown = False }, Cmd.none )

        MouseMove m ->
            case ( m.event, model.seekerMouseIsDown ) of
                ( "mousemove", False ) ->
                    ( model, Cmd.none )

                _ ->
                    let
                        targetPercent =
                            m.x * 100 / m.width

                        targetTime =
                            progressToTime model.equalizeSizes targetPercent

                        --_ =
                        --    Debug.log "targetTime" targetTime
                        --_ =
                        --    Debug.log "mm" m
                    in
                    ( model, setCurrentTime targetTime )

        _ ->
            --Debug.log "Unknown message" (msg)
            --let
            --    _ =
            --        Debug.log "Unknown message" msg
            --    --_ =
            --    --    Debug.log "msg" (Json.Encode.encode 2 msg)
            --in
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onMouseUp (Json.succeed SeekerMouseUp)



-- VIEW
-- This one gets us a nice debug div


debugInfo model =
    let
        currentMovement =
            Movement.currentFromTime model.currentTime

        currentPosix =
            Utils.timeToPosix model.currentTime
    in
    pre []
        [ text
            (Date.format "MMMM ddd, y" (Date.fromPosix utc currentPosix)
                ++ " "
                ++ Utils.formatTime currentPosix
                ++ "\nPrev: "
                --++ "\n"
                ++ Debug.toString (Movement.prev currentMovement)
                ++ " ends @"
                ++ (currentMovement
                        |> Movement.prev
                        |> Movement.ends
                        |> Debug.toString
                   )
                ++ "\nCurrent: "
                ++ Debug.toString currentMovement
                ++ " ends @"
                ++ (currentMovement
                        |> Movement.ends
                        |> Debug.toString
                   )
                ++ "\nNext: "
                --++ "\n"
                ++ Debug.toString (Movement.next currentMovement)
                ++ " ends @"
                ++ (currentMovement
                        |> Movement.next
                        |> Movement.ends
                        |> Debug.toString
                   )
                ++ "\nRemaining: "
                ++ Debug.toString (Movement.remaininigTillNext model.currentTime)
                ++ "\nDate: "
                ++ Date.format "MMMM ddd, y" (Utils.startDate currentMovement)
                --++ Debug.toString (Utils.startDate currentMovement)
                ++ "\nCurrent Time: "
                ++ Debug.toString model.currentTime
                ++ "\n"
                --++ Debug.toString (model.movements |> List.reverse |> List.head)
                ++ "\n"
                ++ .label currentMovement
                ++ "\n"
                ++ (model.currentTime
                        |> Debug.toString
                   )
                ++ "\n"
                ++ (model.currentTime
                        |> Utils.timeToHue
                        |> Debug.toString
                   )
            )

        --(toString (Utils.timeToDate model.currentTime)
        --)
        ]



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


exampleOnClickHandler =
    on "click" (Json.succeed ExampleSimpleMessage)


type alias MouseMovement =
    { event : String
    , x : Float
    , width : Float
    }



--{ x : Float
--}


onSeek : String -> Html.Attribute Msg
onSeek eventName =
    case eventName of
        "touchmove" ->
            on eventName (Json.map MouseMove (mouseMoveDecoder [ "touches", "0", "clientX" ]))

        _ ->
            on eventName (Json.map MouseMove (mouseMoveDecoder [ "clientX" ]))


mouseMoveDecoder : List String -> Json.Decoder MouseMovement
mouseMoveDecoder xPath =
    Json.map3 MouseMovement
        (Json.at [ "type" ] Json.string)
        (Json.at xPath Json.float)
        (Json.at [ "currentTarget", "offsetWidth" ] Json.float)



--onTimeUpdate msg =
--    on "timeupdate" (Json.map msg targetCurrentTime)
--targetCurrentTime : Json.Decoder Float
--targetCurrentTime =
--    Json.at [ "target", "currentTime" ] Json.float


view : Model -> Html Msg
view model =
    let
        currentMovement =
            Movement.currentFromTime model.currentTime

        currentPosix =
            Utils.timeToPosix model.currentTime
    in
    div [ class "container", style "background" (Utils.color (Utils.timeToHue model.currentTime) 50 70) ]
        [ audio
            [ Html.Attributes.id "player"
            , src "./four-seasons.mp3"
            , controls True
            , onTimeUpdate TimeUpdate
            ]
            []
        , debugInfo model
        , div []
            [ div [] [ text (Date.format "MMMM ddd, y" (Date.fromPosix utc currentPosix)) ]
            , div [] [ text "la sonata" ]
            , div [] [ text "deine colore" ]
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
            , div [ class "cursor", style "left" (String.fromFloat (timeToProgress model.equalizeSizes model.currentTime) ++ "%") ] []
            ]
        , Html.label []
            [ Html.input [ type_ "checkbox", Html.Attributes.checked model.equalizeSizes, Html.Events.onClick ToggleSizing ] []
            , text "Equalize Sizes?"
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
        [ text m.label ]



-- INIT


initModel : Model
initModel =
    { currentTime = 0, equalizeSizes = True, title = "", seekerMouseIsDown = False }


type alias Flags =
    { title : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    --Debug.log "flags" flags
    ( { initModel | title = flags.title }, Cmd.none )
