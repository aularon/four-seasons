module Music exposing (Movement)

--import Date exposing (..)
-- Types

import Time exposing (Month)


type alias Movement =
    { index : Int
    , label : String
    , start : Float
    , length : Float
    , hue : Int
    , month : Month
    , day : Int
    }
