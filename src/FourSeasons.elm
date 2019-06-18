module FourSeasons exposing (defaultMovement, firstMovement, fullLength, lastMovement, movements, percentLength, seasons, sonnets, spring)

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


spring =
    Season "Spring" 120 (Array.slice 0 3 movements)


seasons =
    [ spring
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


sonnets =
    [ [ [ "Springtime is upon us."
        , "The birds celebrate her return with festive song,"
        , "and murmuring streams are"
        , "softly caressed by the breezes."
        ]
      , [ "Thunderstorms, those heralds of Spring, roar,"
        , "casting their dark mantle over heaven,"
        , "Then they die away to silence,"
        , "and the birds take up their charming songs once more."
        ]
      ]
    , [ [ "On the flower-strewn meadow, with leafy branches"
        , "rustling overhead, the goat-herd sleeps,"
        , "his faithful dog beside him."
        ]
      ]
    , [ [ "Led by the festive sound of rustic bagpipes,"
        , "nymphs and shepherds lightly dance"
        , "beneath the brilliant canopy of spring."
        ]
      ]
    , [ [ "Under a hard Season, fired up by the Sun"
        , "Languishes man, languishes the flock and burns the pine"
        , "We hear the cuckoo's voice;"
        , "then sweet songs of the turtledove and finch are heard."
        ]
      , [ "Soft breezes stir the air, but threatening"
        , "the North Wind sweeps them suddenly aside."
        , "The shepherd trembles,"
        , "fearing violent storms and his fate."
        ]
      ]
    , [ [ "The fear of lightning and fierce thunder"
        , "Robs his tired limbs of rest"
        , "As gnats and flies buzz furiously around."
        ]
      ]
    , [ [ "Alas, his fears were justified"
        , "The Heavens thunders and roar and with hail"
        , "Cuts the head off the wheat and damages the grain."
        ]
      ]
    , [ [ "Celebrates the peasant, with songs and dances,"
        , "The pleasure of a bountiful harvest."
        , "And fired up by Bacchus' liquor,"
        , "many end their revelry in sleep."
        ]
      ]
    , [ [ "Everyone is made to forget their cares and to sing and dance"
        , "By the air which is tempered with pleasure"
        , "And (by) the season that invites so many, many"
        , "Out of their sweetest slumber to fine enjoyment"
        ]
      ]
    , [ [ "The hunters emerge at the new dawn,"
        , "And with horns and dogs and guns depart upon their hunting"
        , "The beast flees and they follow its trail;"
        ]
      , [ "Terrified and tired of the great noise"
        , "Of guns and dogs, the beast, wounded, threatens"
        , "Languidly to flee, but harried, dies."
        ]
      ]
    , [ [ "To tremble from cold in the icy snow,"
        , "In the harsh breath of a horrid wind;"
        , "To run, stamping one's feet every moment,"
        , "Our teeth chattering in the extreme cold"
        ]
      ]
    , [ [ "Before the fire to pass peaceful,"
        , "Contented days while the rain outside pours down."
        ]
      ]
    , [ [ "We tread the icy path slowly and cautiously,"
        , "for fear of tripping and falling."
        ]
      , [ "Then turn abruptly, slip, crash on the ground and,"
        , "rising, hasten on across the ice lest it cracks up."
        ]
      , [ "We feel the chill north winds course through the home"
        , "despite the locked and bolted doors..."
        , "this is winter, which nonetheless"
        , "brings its own delights."
        ]
      ]
    ]
        |> Array.fromList
