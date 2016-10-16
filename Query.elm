module Query exposing (Model, Msg, init, update, view)

import Color exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import String

-- MODEL

type alias Model =
    { sql : String
    , color : Color
    , period : Int 
    , isActive : Bool
    , isRemoved : Bool
    }

init : Color -> Model
init color =
    Model "" color 10 False False


-- UPDATE

type Msg = 
    ToggleActive
  | SetSql String
  | SetPeriod Int
  | Remove

update : Msg -> Model -> Model
update msg model =
    case msg of
        Remove ->
            {model | isRemoved = True}
        SetPeriod newPeriod ->
            {model | period = newPeriod}
        SetSql newSql ->
            {model | sql = newSql}
        ToggleActive ->
            {model | isActive = not model.isActive}
        
-- VIEW

view : Model -> Html Msg
view model =
    let buttonText = if model.isActive && model.period > 0 then "Stop" else "Run"
        colorStr c = String.concat ["rgb(" 
            , (c |> toRgb |> .red |> toString), ", "
            , (c |> toRgb |> .green |> toString), ", "
            , (c |> toRgb |> .blue |> toString), ")"]
    in
    div [class "query"]
        [ div [style [("background-color", colorStr model.color), ("height", "4px"), ("width", "100%")]][]
        , textarea [placeholder "Enter SQL", onInput SetSql] []
        , button [ onClick ToggleActive ] [ text buttonText ]
        , button [ onClick Remove ] [ text "Remove" ]
        ]