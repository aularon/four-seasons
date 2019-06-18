module FourSeasons.Utils exposing (color, dateToMillis, distortedProgressToTime, formatTime, monthDayToTime, movementColor, progressToTime, rangeMap, startDate, startOf1988, stringToMonth, timeToDate, timeToDistortedProgress, timeToHue, timeToPosix, timeToProgress)

--import Date exposing (Date, Month(..))
--import Parser

import Array
import Color exposing (Color)
import Date exposing (Date)
import FourSeasons exposing (defaultMovement, firstMovement, fullLength, lastMovement, movements, percentLength)
import Music exposing (Movement)
import Music.Movement as Movement
import Time exposing (Month(..), Posix, millisToPosix, posixToMillis, toHour, toMinute, utc)



-- number of seconds between 1970-01-01 and 1988-01-01


startOf1988 =
    567993600000



-- takes current audio time and gives us back a posix date


timeToPosix : Float -> Posix
timeToPosix currentTime =
    let
        currentMovement =
            Movement.currentFromTime currentTime

        nextMovement =
            Movement.next currentMovement

        start =
            startDate currentMovement

        end =
            startDate nextMovement

        s =
            dateToMillis start

        e =
            dateToMillis end
                + (if
                    Jan == nextMovement.month
                    -- Add full year, so it is Jan 1989
                    -- FIXME should we add 366 days since 1988 is a leap year?
                   then
                    1.0e3 * 86400 * 365

                   else
                    0.0
                  )

        --newTime = (currentTime - currentMovement.start)/(Movement.ends currentMovement - currentMovement.start) * (e - s) + s
    in
    millisToPosix (round (rangeMap currentTime currentMovement.start (Movement.ends currentMovement) s e))



-- takes current audio time and gives us Date


timeToDate : Float -> Date
timeToDate currentTime =
    Date.fromPosix utc (timeToPosix currentTime)



--Date.fromTime (567993600000 + (currentTime/2520.38117) * 1e3 * 86400 * 365)


dateToMillis : Date -> Float
dateToMillis date =
    toFloat (Date.ordinalDay date - 1) * 1.0e3 * 86400 + startOf1988



-- maps a value from one range to another


rangeMap : Float -> Float -> Float -> Float -> Float -> Float
rangeMap oldVal oldMin oldMax newMin newMax =
    (oldVal - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin



-- gets the start date from a movement


startDate : Movement -> Date
startDate movement =
    Date.fromCalendarDate 1988 movement.month movement.day



-- gets an hsl(,,) css string representation from a movement and saturation/luminisity pair


color : Float -> Int -> Int -> String
color h s l =
    "hsl(" ++ String.join "," [ String.fromFloat h, String.fromInt s ++ "%", String.fromInt l ++ "%" ] ++ ")"


movementColor : Movement -> Float -> Float -> Color
movementColor m s l =
    Color.hsl (m.hue / 360) s l



-- formats time, used in debugging for now


formatTime : Posix -> String
formatTime posix =
    (posix |> toHour utc |> String.fromInt |> String.padLeft 2 '0')
        ++ ":"
        ++ (posix |> toMinute utc |> String.fromInt |> String.padLeft 2 '0')



--let
--  c = Color.fromHsl (degrees movement.hue) s l
--in
-- the center of the movement is its hue
-- this function returns a hue that changes gradually with time


timeToHue : Float -> Float
timeToHue time =
    let
        currentMovement =
            Movement.currentFromTime time

        currentCenter =
            Movement.center currentMovement

        isFirstHalf =
            time < currentCenter

        ( m1, m2 ) =
            if isFirstHalf then
                ( Movement.prev currentMovement, currentMovement )

            else
                ( currentMovement, Movement.next currentMovement )

        -- we are repeating the extraction for the current center
        firstCenter =
            Movement.center m1

        secondCenter =
            Movement.center m2
    in
    case ( currentMovement.index, isFirstHalf ) of
        ( 0, True ) ->
            --let
            --    _ =
            --        Debug.log "hue" { time = time, secondCenter = secondCenter, m2h = m2.hue }
            --in
            rangeMap time 0 secondCenter 170 m2.hue

        ( 11, False ) ->
            rangeMap time firstCenter fullLength m1.hue 170

        ( _, _ ) ->
            if m1.hue == 0 then
                rangeMap time firstCenter secondCenter 360 m2.hue

            else
                rangeMap time firstCenter secondCenter m1.hue m2.hue



-- converts month/day into audio track time


monthDayToTime : Month -> Int -> Float
monthDayToTime m d =
    let
        date =
            Date.fromCalendarDate 1988 m d

        movement =
            Movement.currentFromDate date

        start =
            movement |> startDate |> dateToMillis

        end =
            movement |> Movement.next |> startDate |> dateToMillis

        current =
            date |> dateToMillis

        --_ =
        --    Debug.log "jun19date" (dateToMillis (Date.fromCalendarDate 1988 Jun 19))
    in
    rangeMap current start end movement.start (Movement.ends movement)


stringToMonth : String -> Month
stringToMonth str =
    case String.toUpper str of
        -- console.log('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split(' ').map(m=>`"${m.toUpperCase()}" -> ${m}`).join('\n'))
        "JAN" ->
            Jan

        "FEB" ->
            Feb

        "MAR" ->
            Mar

        "APR" ->
            Apr

        "MAY" ->
            May

        "JUN" ->
            Jun

        "JUL" ->
            Jul

        "AUG" ->
            Aug

        "SEP" ->
            Sep

        "OCT" ->
            Oct

        "NOV" ->
            Nov

        "DEC" ->
            Dec

        _ ->
            Jun



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
