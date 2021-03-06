module Music exposing (Movement)

--import Date exposing (..)
-- Types

import Time exposing (Month)


type alias Movement =
    { index : Int
    , tempo : String
    , scale : String
    , start : Float
    , length : Float
    , hue : Float
    , month : Month
    , day : Int
    }
