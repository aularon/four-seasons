module FourSeasons.Utils exposing (..)

import Time exposing (Time)
import Date exposing (Date, Month(Jan))
import Music exposing (Movement)
import Music.Movement as Movement
--import Color exposing (Color)


startOf1988 = 567993600000
timeToDate: Time -> Date
timeToDate currentTime = 
  let
    currentMovement = Movement.currentFromTime currentTime
    nextMovement = Movement.next currentMovement
    start = startDate currentMovement
    end = startDate nextMovement
    s = Date.toTime start
    e = Date.toTime end + if Jan == nextMovement.month
                          -- Add full year, so it is Jan 1989
                          -- FIXME should we add 366 days since 1988 is a leap year?
                          then 1e3 * 86400 * 365
                          else 0
    --newTime = (currentTime - currentMovement.start)/(Movement.ends currentMovement - currentMovement.start) * (e - s) + s
  in
    Date.fromTime (rangeMap currentTime currentMovement.start (Movement.ends currentMovement) s e)
  --Date.fromTime (567993600000 + (currentTime/2520.38117) * 1e3 * 86400 * 365)

rangeMap: Float -> Float -> Float -> Float -> Float -> Float
rangeMap oldVal oldMin oldMax newMin newMax =
  (oldVal - oldMin)/(oldMax - oldMin) * (newMax - newMin) + newMin

startDate: Movement -> Date
startDate movement =
  case Date.fromString (toString movement.month ++ " " ++ toString movement.day ++ ", 1988") of
    --Result String d -> d
    Ok d -> d
    Err e -> timeToDate 0


color: Movement -> Int -> Int -> String
color movement s l =
  "hsl(" ++ (String.join "," [toString movement.hue, toString s ++ "%", toString l ++ "%"] ) ++ ")"
  --let
  --  c = Color.fromHsl (degrees movement.hue) s l
  --in
