port module FourSeasonsApp exposing (main)

import Array
import Browser exposing (UrlRequest)
import Browser.Events
import Browser.Navigation
import Common exposing (Model, MouseMovement, Msg(..))
import FourSeasons exposing (..)
import FourSeasons.Utils as Utils
import Json.Decode as Json
import Json.Encode
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



-- elm says "there is often a better way to set things up."


port playPause : () -> Cmd msg



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

        Play ->
            ( { model | isPlaying = True }, Cmd.none )

        Pause ->
            ( { model | isPlaying = False }, Cmd.none )

        PlayPause ->
            ( model, playPause () )

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
    { title : String }


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url navkey =
    let
        --_ =
        --    Debug.log "jun19" (Utils.monthDayToTime Time.Jun 19)
        startTime =
            case url.fragment of
                Just str ->
                    if String.endsWith "s" str then
                        -- Seconds
                        Maybe.withDefault 0 (str |> String.dropRight 1 |> String.toFloat)

                    else
                        let
                            month =
                                Utils.stringToMonth (String.left 3 str)

                            day =
                                Maybe.withDefault 19 (str |> String.dropLeft 3 |> String.toInt)
                        in
                        Utils.monthDayToTime month day

                Nothing ->
                    0
    in
    --Debug.log "flags" flags
    ( { initModel | currentTime = startTime }, setCurrentTime startTime )
