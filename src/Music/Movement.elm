module Music.Movement exposing (center, currentFromTime, ends, next, remaininigTillNext)

--import Date exposing (Date)

import FourSeasons exposing (..)
import Music exposing (Movement)



--length: List Movement -> Movement -> Time
--length movements m =
-- figures out current movement from current time stamp


currentFromTime : Float -> Movement
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



-- gets next movement or first one (if we got last)


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
