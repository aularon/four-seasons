port module FourSeasonsApp exposing (main)

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
    }



-- MSG
-- Different type of messages we get to our update function


type Msg
    = NoOp
    | TimeUpdate Float
    | SetTime Float
    | ToggleSizing



-- Custom event handler
-- Used in the view to handle the audio's `timeupdate`


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)


targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float



-- 100% split among the 12 movements


percentLength =
    100 / 12



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

        _ =
            Debug.log "debug 77:" ( baseProgress, extraProgress )
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

        _ ->
            --Debug.log "Unknown message" (msg)
            Debug.log "Unknown message" ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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



-- our main view div


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



-- view helper, gets a listing LI from movement


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
