module FourSeasons.Utils exposing (color, formatTime, rangeMap, startDate, startOf1988, timeToDate, timeToPosix)

--import Date exposing (Date, Month(..))

import Date exposing (Date)
import Music exposing (Movement)
import Music.Movement as Movement
import Time exposing (Month(..), Posix, millisToPosix, posixToMillis, toHour, toMinute, utc)



--import Color exposing (Color)


startOf1988 =
    567993600000


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


timeToDate : Float -> Date
timeToDate currentTime =
    Date.fromPosix utc (timeToPosix currentTime)



--Date.fromTime (567993600000 + (currentTime/2520.38117) * 1e3 * 86400 * 365)


dateToMillis : Date -> Float
dateToMillis date =
    toFloat (Date.ordinalDay date) * 1.0e3 * 86400 + startOf1988


rangeMap : Float -> Float -> Float -> Float -> Float -> Float
rangeMap oldVal oldMin oldMax newMin newMax =
    (oldVal - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin


startDate : Movement -> Date
startDate movement =
    Date.fromCalendarDate 1988 movement.month movement.day


color : Movement -> Int -> Int -> String
color movement s l =
    "hsl(" ++ String.join "," [ String.fromInt movement.hue, String.fromInt s ++ "%", String.fromInt l ++ "%" ] ++ ")"


formatTime : Posix -> String
formatTime posix =
    String.fromInt (toHour utc posix)
        ++ ":"
        ++ String.fromInt (toMinute utc posix)



--let
--  c = Color.fromHsl (degrees movement.hue) s l
--in
