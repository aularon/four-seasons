module Common exposing (InfoState(..), Model, MouseMovement, Msg(..))

-- MODEL


type alias Model =
    { currentTime : Float
    , equalizeSizes : Bool
    , title : String
    , seekerMouseIsDown : Bool
    , isPlaying : Bool
    , seekTime : Float
    , infoState : InfoState
    }



-- MSG
-- Different type of messages we get to our update function


type InfoState
    = Start
    | Hidden
    | Shown


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
    | ExternalAction String
    | ToggleInfo


type alias MouseMovement =
    { event : String
    , x : Float
    , width : Float
    }
