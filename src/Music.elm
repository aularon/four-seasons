module Music exposing (Movement)

import Date exposing (..)
import Time exposing (Time)



-- Types


type alias Movement =
    { index : Int
    , label : String
    , start : Time
    , length : Time
    , hue : Int
    , month : Month
    , day : Int
    }
