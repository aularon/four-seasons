module Music.Movement exposing (center, currentFromTime, ends, next, percentWidth, prev, remaininigTillNext)

--import Date exposing (Date)

import Array
import FourSeasons exposing (..)
import Music exposing (Movement)



--length: List Movement -> Movement -> Time
--length movements m =
-- figures out current movement from current time stamp


currentFromTime : Float -> Movement
currentFromTime currentTime =
    case
        movements
            |> Array.filter (\x -> x.start + x.length > currentTime)
            |> Array.get 0
    of
        Nothing ->
            defaultMovement

        Just val ->
            val



-- gets next movement or first one (if we got last)


next : Movement -> Movement
next currentMovement =
    case
        movements
            |> Array.get (currentMovement.index + 1)
    of
        Nothing ->
            firstMovement

        Just val ->
            val


prev : Movement -> Movement
prev currentMovement =
    case
        movements
            |> Array.get (currentMovement.index - 1)
    of
        Nothing ->
            lastMovement

        Just val ->
            val



-- returns the end timestamp of a movement


ends : Movement -> Float
ends m =
    m.start + m.length


center : Movement -> Float
center m =
    (m.start + ends m) / 2



-- how much time is left until the next movement/end of the track


remaininigTillNext : Float -> Float
remaininigTillNext currentTime =
    let
        current =
            currentFromTime currentTime
    in
    ends current - currentTime


percentWidth : Bool -> Movement -> Float
percentWidth equalizeSizes m =
    case equalizeSizes of
        True ->
            percentLength

        False ->
            m.length / fullLength * 100
