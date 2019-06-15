module FourSeasons.Utils exposing (color, formatTime, movementColor, rangeMap, startDate, startOf1988, timeToDate, timeToHue, timeToPosix)

--import Date exposing (Date, Month(..))
--import Color exposing (Color)

import Date exposing (Date)
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
    toFloat (Date.ordinalDay date) * 1.0e3 * 86400 + startOf1988



-- maps a value from one range to another


rangeMap : Float -> Float -> Float -> Float -> Float -> Float
rangeMap oldVal oldMin oldMax newMin newMax =
    (oldVal - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin



-- gets the start date from a movement


startDate : Movement -> Date
startDate movement =
    Date.fromCalendarDate 1988 movement.month movement.day



-- gets an hsl(,,) css string representation from a movement and saturation/luminisity pair


movementColor : Movement -> Int -> Int -> String
movementColor m s l =
    color (toFloat m.hue) s l


color : Float -> Int -> Int -> String
color h s l =
    "hsl(" ++ String.join "," [ String.fromFloat h, String.fromInt s ++ "%", String.fromInt l ++ "%" ] ++ ")"



-- formats time, used in debugging for now


formatTime : Posix -> String
formatTime posix =
    String.fromInt (toHour utc posix)
        ++ ":"
        ++ String.fromInt (toMinute utc posix)



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

        ( firstMovement, secondMovement ) =
            if time < currentCenter then
                ( Movement.prev currentMovement, currentMovement )

            else
                ( currentMovement, Movement.next currentMovement )

        -- we are repeating the extraction for the current center
        firstCenter =
            Movement.center firstMovement

        secondCenter =
            Movement.center secondMovement

        _ =
            Debug.log "hue" { time = time, firstCenter = firstCenter, secondCenter = secondCenter, fh = firstMovement.hue, sh = secondMovement.hue }
    in
    if firstMovement.hue == 0 then
        rangeMap time firstCenter secondCenter 360 (toFloat secondMovement.hue)

    else
        rangeMap time firstCenter secondCenter (toFloat firstMovement.hue) (toFloat secondMovement.hue)
