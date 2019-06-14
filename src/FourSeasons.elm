module FourSeasons exposing (defaultMovement, firstMovement, fullLength, movements)

import Date exposing (..)
import Music exposing (Movement)



--type alias ExtendedMovement = {Movement | end: Time}


firstMovement =
    Movement 0 "Allegro (in E major)" 0 222 150 Mar 21


movements =
    [ firstMovement
    , Movement 1 "Largo e pianissimo sempre (in C-sharp minor)" 222 160 120 Apr 21
    , Movement 2 "Allegro pastorale (in E major)" 382 266 90 May 21
    , Movement 3 "Allegro non molto (in G minor)" 648 292 75 Jun 21
    , Movement 4 "Adagio e piano - Presto e forte (in G minor)" 940 127 60 Jul 22
    , Movement 5 "Presto (in G minor)" 1067 191 45 Aug 22
    , Movement 6 "Allegro (in F major)" 1258 350 20 Sep 23
    , Movement 7 "Adagio molto (in D minor)" 1608 128 0 Oct 23
    , Movement 8 "Allegro (in F major)" 1736 226 340 Nov 22
    , Movement 9 "Allegro non molto (in F minor)" 1962 239 280 Dec 21
    , Movement 10 "Largo (in E-flat major)" 2201 136 220 Jan 21
    , Movement 11 "Allegro (in F minor)" 2337 183 180 Feb 21
    ]



--defaultMovement = Movement "-" -1 -1 -1 Mar 21


defaultMovement =
    firstMovement


fullLength =
    2520.4
