port module FourSeasonsApp exposing (Flags, Model, Msg(..), debugInfo, distortedProgressToTime, init, initModel, main, movementToLi, onTimeUpdate, percentLength, progressToTime, setCurrentTime, setProgress, subscriptions, targetCurrentTime, timeToDistortedProgress, timeToProgress, update, view)

--import Date exposing (Date)

import Browser
import Date exposing (Date)
import FourSeasons exposing (..)
import FourSeasons.Utils as Utils
import Html exposing (Attribute, Html, audio, div, li, pre, text, ul)
import Html.Attributes exposing (class, classList, controls, src, style, type_)
import Html.Events exposing (on)
import Json.Decode as Json
import Music exposing (Movement)
import Music.Movement as Movement
import Time exposing (utc)
import Types exposing (Time)



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
    { currentTime : Time
    , equalizeSizes : Bool
    , title : String
    }



-- MSG


type Msg
    = NoOp
    | TimeUpdate Float
    | SetTime Float
    | ToggleSizing



-- Custom event handler


onTimeUpdate : (Time -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)


targetCurrentTime : Json.Decoder Time
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float



--
--


setProgress : Bool -> String -> Msg
setProgress equalizeSizes input =
    SetTime (progressToTime equalizeSizes (Maybe.withDefault 0 (String.toFloat input)))



-- function and its inverse


percentLength =
    8.3333


progressToTime : Bool -> Float -> Float
progressToTime equalizeSizes progress =
    case equalizeSizes of
        True ->
            distortedProgressToTime progress

        False ->
            progress * fullLength / 100


distortedProgressToTime : Float -> Float
distortedProgressToTime progress =
    let
        movementNumber =
            floor (progress / percentLength)

        movement =
            case movements |> List.drop movementNumber |> List.head of
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


timeToProgress : Bool -> Float -> Float
timeToProgress equalizeSizes time =
    case equalizeSizes of
        True ->
            timeToDistortedProgress time

        False ->
            time * 100 / fullLength


timeToDistortedProgress : Float -> Float
timeToDistortedProgress time =
    let
        currentMovement =
            Movement.currentFromTime time

        baseProgress =
            toFloat currentMovement.index * percentLength

        extraProgress =
            (time - currentMovement.start) * percentLength / currentMovement.length

        _ =
            Debug.log "debug 77:" ( baseProgress, extraProgress )
    in
    baseProgress + extraProgress



-- PORT


port setCurrentTime : Float -> Cmd msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate time ->
            ( { model | currentTime = time }, Cmd.none )

        SetTime newTime ->
            ( model, setCurrentTime newTime )

        ToggleSizing ->
            ( { model | equalizeSizes = not model.equalizeSizes }, Cmd.none )

        _ ->
            --Debug.log "Unknown message" (msg)
            Debug.log "Unknown message" ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


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
                ++ "\n"
                --++ "\n"
                ++ Debug.toString (Movement.next currentMovement)
                ++ "\n"
                ++ Debug.toString (Movement.remaininigTillNext model.currentTime)
                ++ "\n"
                ++ Date.format "MMMM ddd, y" (Utils.startDate currentMovement)
                --++ Debug.toString (Utils.startDate currentMovement)
                ++ "\n"
                ++ Debug.toString model.currentTime
                ++ "\n"
                --++ Debug.toString (model.movements |> List.reverse |> List.head)
                ++ "\n"
                ++ .label currentMovement
            )

        --(toString (Utils.timeToDate model.currentTime)
        --)
        ]


view : Model -> Html Msg
view model =
    let
        currentMovement =
            Movement.currentFromTime model.currentTime
    in
    div [ class "container", style "background" (Utils.color currentMovement 50 70) ]
        [ audio
            [ Html.Attributes.id "player"
            , src "./four-seasons.mp3"
            , controls True
            , onTimeUpdate TimeUpdate
            ]
            []
        , debugInfo model
        , div [ class "seeker" ]
            [ Html.ul [] (List.map (\m -> movementToLi m model) movements)
            , Html.input
                [ type_ "range"
                , Html.Attributes.max "100"
                , Html.Attributes.step "0.01"
                , Html.Attributes.value (String.fromFloat (timeToProgress model.equalizeSizes model.currentTime))
                , Html.Events.onInput (setProgress model.equalizeSizes)
                ]
                []
            ]
        , Html.label []
            [ Html.input [ type_ "checkbox", Html.Attributes.checked model.equalizeSizes, Html.Events.onClick ToggleSizing ] []
            , text "Equalize Sizes?"
            ]
        ]


movementToLi : Movement -> Model -> Html msg
movementToLi m model =
    let
        currentMovement =
            Movement.currentFromTime model.currentTime

        width =
            case model.equalizeSizes of
                True ->
                    percentLength

                False ->
                    m.length / fullLength * 100
    in
    li
        [ classList [ ( "active", m == currentMovement ) ]
        , style "background" (Utils.color m 70 40)
        , style "width" (String.fromFloat width ++ "%")
        ]
        [ text m.label ]



-- INIT


initModel : Model
initModel =
    { currentTime = 0, equalizeSizes = True, title = "" }


type alias Flags =
    { title : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    --Debug.log "flags" flags
    ( { initModel | title = flags.title }, Cmd.none )



-- Functions
--TimeToHue : Integer -> Integer
--TimeToHue =
