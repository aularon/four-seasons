module Common exposing (Model, MouseMovement, Msg(..))

-- MODEL


type alias Model =
    { currentTime : Float
    , equalizeSizes : Bool
    , title : String
    , seekerMouseIsDown : Bool
    , isPlaying : Bool
    }



-- MSG
-- Different type of messages we get to our update function


type Msg
    = NoOp
    | ExampleSimpleMessage
    | TimeUpdate Float
    | MouseMove MouseMovement
    | SetTime Float
    | ToggleSizing
    | SeekerMouseDown
    | SeekerMouseUp
    | Play
    | Pause
    | PlayPause String


type alias MouseMovement =
    { event : String
    , x : Float
    , width : Float
    }
