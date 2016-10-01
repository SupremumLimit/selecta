module Query exposing ( Model, Msg, init, update, view )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

-- MODEL

type alias Model =
    { sql : String
    , color : String
    , period : Int 
    , isActive : Bool
    , isRemoved : Bool
    }

init : Model
init =
    Model "" "fff" 10 False False


-- UPDATE

type Msg = 
    ToggleActive
  | SetSql String
  | SetPeriod Int
  | Remove

update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleActive ->
            {model | isActive = not model.isActive}
        SetSql newSql ->
            {model | sql = newSql}
        SetPeriod newPeriod ->
            {model | period = newPeriod}
        Remove ->
            {model | isRemoved = True} 

-- VIEW

view : Model -> Html Msg
view model =
    let buttonText = if model.isActive && model.period > 0 then "Stop" else "Run"
    in
    div [class "query"]
        [ textarea [placeholder "Enter SQL", onInput SetSql] []
        , button [ onClick ToggleActive ] [ text buttonText ]
        , button [ onClick Remove ] [ text "Remove" ]
        ]