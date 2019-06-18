module FourSeasons exposing (defaultMovement, firstMovement, fullLength, lastMovement, movements, percentLength, seasons)

--import Date exposing (..)

import Array
import Music exposing (Movement)
import Time exposing (Month(..))



--type alias ExtendedMovement = {Movement | end: Time}


firstMovement =
    Movement 0 "Allegro" "E major" 0 222 150 Mar 21


lastMovement =
    Movement 11 "Allegro" "F minor" 2337 183 180 Feb 21


movements =
    [ firstMovement
    , Movement 1 "Largo e pianissimo sempre" "C-sharp minor" 222 160 120 Apr 21
    , Movement 2 "Allegro pastorale" "E major" 382 266 90 May 21
    , Movement 3 "Allegro non molto" "G minor" 648 292 75 Jun 21
    , Movement 4 "Adagio e piano - Presto e forte" "G minor" 940 127 60 Jul 22
    , Movement 5 "Presto" "G minor" 1067 191 45 Aug 22
    , Movement 6 "Allegro" "F major" 1258 350 20 Sep 23
    , Movement 7 "Adagio molto" "D minor)" 1608 128 0 Oct 23
    , Movement 8 "Allegro" "F major" 1736 226 340 Nov 22
    , Movement 9 "Allegro non molto" "F minor" 1962 239 280 Dec 21
    , Movement 10 "Largo" "E-flat major" 2201 136 220 Jan 21
    , lastMovement
    ]
        |> Array.fromList


type alias Season =
    { name : String
    , hue : Float
    , movements : Array.Array Movement
    }


seasons =
    [ Season "Spring" 120 (Array.slice 0 3 movements)
    , Season "Summer" 60 (Array.slice 3 6 movements)
    , Season "Autumn" 0 (Array.slice 6 9 movements)
    , Season "Winter" 220 (Array.slice 9 12 movements)
    ]
        |> Array.fromList



--defaultMovement = Movement "-" -1 -1 -1 Mar 21


defaultMovement =
    firstMovement


fullLength =
    2520.4


percentLength =
    100 / 12
