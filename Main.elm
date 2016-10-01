import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http 
import Json.Decode as Json exposing (..)
import Json.Encode as JsonEncode exposing (..)
import Task exposing (..)
import Time exposing (..)

import Shared exposing (..)

import GeoJson exposing (..)
--import GeoJsonDecoder exposing (..)
import Ports
import Query
import Uplink

-- MODEL

type alias Model =
    { currentResultSet : QueryResultSet
    , password : String
    , queries : List IndexedQuery
    , serverUrl : ServerUrl
    , sessionId : SessionId
    , uid : Int 
    , username : String
    }
  
type alias IndexedQuery =
    { id : Int
    , model : Query.Model
    }  

type alias QueryResultSet = List (String, GeoJson) -- (List (String, List (String, Int)))

init : (Model, Cmd Msg)
init =
   ({ currentResultSet = []
    , password = "***REMOVED***"
    , queries = [] 
    , serverUrl = "http://localhost:3000/v4" -- "https://csl-safesitenode-staging.herokuapp.com" 
    , sessionId = Nothing
    , uid = 0
    , username = "***REMOVED***"
    }, Cmd.none)


-- UPDATE

type Msg = 
      Insert 
    | Login
    | LoginSucceed String
    | LoginFail Http.Error
    | Modify Int Query.Msg    
    | QueriesFail Http.Error
    | QueriesSucceed QueryResultSet
    | SetPassword String
    | SetServerUrl ServerUrl
    | SetUsername String
    | Tick Time


-- Update helpers
dropDeletedQueries = 
    List.filter (\q -> q.model.isRemoved == False) 
updateIndexedQuery qid qmsg {id, model} = 
    IndexedQuery id (if qid == id then Query.update qmsg model else model)
updateIndexedQueries qid qmsg = 
    List.map (updateIndexedQuery qid qmsg)


decodeSessionId : Json.Decoder String
decodeSessionId = Json.at ["sessionId"] Json.string

-- TODO: decide on format for results - all of them have to be displayable on the map
decodeQueryResults : Decoder QueryResultSet
decodeQueryResults = Json.keyValuePairs GeoJson.decoder


-- {"0":{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":[{"type":"Polygon","coordinates":[[[174.748699375402,-41.260793543852]

login : ServerUrl -> String -> String -> Cmd Msg
login serverUrl username password =
    let body = [("email", JsonEncode.string username), ("password", JsonEncode.string password)] 
                |> JsonEncode.object |> JsonEncode.encode 0 |> Http.string
    in
        Task.perform LoginFail LoginSucceed 
            (Uplink.post decodeSessionId serverUrl Nothing "users-hq/login" body)
            
            
execQueries : ServerUrl -> SessionId -> List IndexedQuery -> Cmd Msg
execQueries serverUrl sessionId queries =
    case sessionId of 
        Nothing ->
            Cmd.none
        Just s ->
            let body = queries |> List.map (\q -> (toString q.id, JsonEncode.string q.model.sql)) 
                        |> JsonEncode.object |> JsonEncode.encode 0 |> Http.string
            in 
                Task.perform QueriesFail QueriesSucceed 
                    (Uplink.post decodeQueryResults serverUrl sessionId "internal/geoJsonQueries" body)
     
 
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Insert -> 
            ({ model
                | queries = model.queries ++ [ IndexedQuery model.uid (Query.init) ]  
                , uid = model.uid + 1
            }, Cmd.none)

        Login ->
            (model, login model.serverUrl model.username model.password)
            
        LoginSucceed sessionId ->
            ({ model | sessionId = Just sessionId }, Cmd.none)

        LoginFail _ ->
            (model, Cmd.none)        

        Modify id qmsg ->
            ({ model | 
                queries = dropDeletedQueries (updateIndexedQueries id qmsg model.queries)
            }, Cmd.none)
  
        QueriesFail _ ->
            ({model | currentResultSet = Debug.log "Fail" model.currentResultSet}, Cmd.none)
            
        QueriesSucceed queryResultSet -> 
            ({model | currentResultSet = queryResultSet}, 
                queryResultSet |> List.map (\q -> (fst q, GeoJson.encode (snd q))) 
                    |> JsonEncode.object |> Ports.mapData)
        
        SetPassword password ->
            ({ model | password = password }, Cmd.none)
             
        SetServerUrl url -> 
            ({ model | serverUrl = url }, Cmd.none)
            
        SetUsername name ->
            ({ model | username = name }, Cmd.none)

        Tick time -> 
            --(model, model.queries |> List.map (\q -> q.model.sql) |> Ports.mapData)
            (model, execQueries model.serverUrl model.sessionId model.queries)
      
-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Time.every (10 * second) Tick

-- VIEW 

viewLogin : Model -> Html Msg
viewLogin model = 
    div [class "login"] 
    [ input [placeholder "Server address", onInput SetServerUrl, Html.Attributes.value model.serverUrl] []
    , input [placeholder "HQ user name", onInput SetUsername, Html.Attributes.value model.username] []
    , input [placeholder "HQ password", onInput SetPassword, Html.Attributes.value model.password]  []
    , button [ onClick Login ] [ text "Login" ]
    ] 

viewMain : Model -> Html Msg
viewMain model =
    let
        viewIndexedQuery {id, model} =
            div [class "queryContainer"] [text (toString id), App.map (Modify id) (Query.view model)]
        serverBlock = 
            div [class "server"][
            ]
        queryBlocks =
            List.map viewIndexedQuery model.queries
        addQuery =
            button [ onClick Insert ] [ text "Add query" ]
    in
        div [] ([serverBlock] ++ queryBlocks ++ [addQuery])
  
  
view : Model -> Html Msg
view model = 
    case model.sessionId of 
        Nothing -> viewLogin model
        Just _ -> viewMain model
    

main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }