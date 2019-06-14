module Music exposing (Movement)

--import Date exposing (..)
-- Types

import Time exposing (Month)
import Types exposing (Time)


type alias Movement =
    { index : Int
    , label : String
    , start : Time
    , length : Time
    , hue : Int
    , month : Month
    , day : Int
    }
