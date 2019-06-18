port module FourSeasonsApp exposing (main)

import Array
import Browser exposing (UrlRequest)
import Browser.Events
import Browser.Navigation
import Common exposing (Model, MouseMovement, Msg(..))
import Date
import FourSeasons exposing (..)
import FourSeasons.Utils as Utils
import Json.Decode as Json
import Json.Encode
import Time exposing (utc)
import Url exposing (Url)
import View exposing (view)



-- Main


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }


onUrlChange : Url -> Msg
onUrlChange url =
    NoOp


onUrlRequest : UrlRequest -> Msg
onUrlRequest urlReq =
    NoOp



-- 100% split among the 12 movements
-- This one takes current progress as input (along current equalizeSizes flag) and emits a SetTime Msg
-- Used in the range input (slider) onInput handler


setProgress : Bool -> String -> Msg
setProgress equalizeSizes input =
    SetTime (Utils.progressToTime equalizeSizes (Maybe.withDefault 0 (String.toFloat input)))



-- PORT
-- this is subscribed to from javascript side


port setCurrentTime : Float -> Cmd msg


port playPause : String -> Cmd msg


port modifyUrl : String -> Cmd msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        currentPosix =
            Utils.timeToPosix model.currentTime

        currentDate =
            Date.fromPosix utc currentPosix
    in
    case msg of
        -- The audio is playing and we get an update
        TimeUpdate time ->
            ( { model | currentTime = time }, modifyUrl ("/date/" ++ Date.format "MMM/dd" currentDate) )

        -- The user seeks to a new timing
        SetTime newTime ->
            ( model, setCurrentTime newTime )

        ToggleSizing ->
            ( { model | equalizeSizes = not model.equalizeSizes }, Cmd.none )

        SeekerMouseDown ->
            ( { model | seekerMouseIsDown = True }, Cmd.none )

        SeekerMouseUp ->
            ( { model | seekerMouseIsDown = False }, Cmd.none )

        Play ->
            ( { model | isPlaying = True }, Cmd.none )

        Pause ->
            ( { model | isPlaying = False }, Cmd.none )

        PlayPause action ->
            ( model, playPause action )

        MouseMove m ->
            case ( m.event, model.seekerMouseIsDown ) of
                ( "mousemove", False ) ->
                    ( model, Cmd.none )

                _ ->
                    let
                        targetPercent =
                            m.x * 100 / m.width

                        targetTime =
                            Utils.progressToTime model.equalizeSizes targetPercent

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



--onTimeUpdate msg =
--    on "timeupdate" (Json.map msg targetCurrentTime)
--targetCurrentTime : Json.Decoder Float
--targetCurrentTime =
--    Json.at [ "target", "currentTime" ] Json.float
-- INIT


initModel : Model
initModel =
    { currentTime = 0, equalizeSizes = True, title = "", seekerMouseIsDown = False, isPlaying = False }


type alias Flags =
    { now : Int }


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url navkey =
    let
        --    Debug.log "jun19" (Utils.monthDayToTime Time.Jun 19)
        str =
            url.path

        startTime =
            if String.startsWith "/time/" str then
                -- Seconds
                Maybe.withDefault 0 (str |> String.dropLeft 6 |> String.toFloat)

            else if String.startsWith "/date/" str then
                case str |> String.dropLeft 6 |> String.split "/" of
                    [ monthStr, dayStr ] ->
                        let
                            month =
                                monthStr |> Utils.stringToMonth

                            day =
                                dayStr |> String.toInt |> Maybe.withDefault 19
                        in
                        Utils.monthDayToTime month day

                    [ monthStr ] ->
                        Utils.monthDayToTime (monthStr |> Utils.stringToMonth) 1

                    _ ->
                        0
                --day =
                --    str
                --        |> String.slice 10
                --        |> Utils.stringToMonth
                --            Maybe.withDefault
                --            19
                --            (str |> String.dropLeft 3 |> String.toInt)

            else
                let
                    today =
                        flags.now |> Time.millisToPosix |> Date.fromPosix utc
                in
                Utils.monthDayToTime (Date.month today) (Date.day today)
    in
    --Debug.log "flags" flags
    ( { initModel | currentTime = startTime }, setCurrentTime startTime )
