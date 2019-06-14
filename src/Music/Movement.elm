module Music.Movement exposing (currentFromTime, ends, next, remaininigTillNext)

import Date exposing (Date)
import FourSeasons exposing (..)
import Music exposing (Movement)
import Time exposing (Time)



--length: List Movement -> Movement -> Time
--length movements m =


currentFromTime : Time -> Movement
currentFromTime currentTime =
    case
        movements
            |> List.filter (\x -> x.start + x.length > currentTime)
            |> List.head
    of
        Nothing ->
            defaultMovement

        Just val ->
            val


next : Movement -> Movement
next currentMovement =
    let
        loopingMovements =
            movements

        nextFromMovements l =
            case l of
                x :: [] ->
                    firstMovement

                x :: y :: rest ->
                    if x == currentMovement then
                        y

                    else
                        nextFromMovements (y :: rest)

                _ ->
                    defaultMovement
    in
    nextFromMovements loopingMovements


ends : Movement -> Time
ends m =
    m.start + m.length


remaininigTillNext : Time -> Time
remaininigTillNext currentTime =
    let
        current =
            currentFromTime currentTime
    in
    ends current - currentTime
