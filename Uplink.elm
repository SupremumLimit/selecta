module Uplink exposing (post)

import Json.Decode as Json
import Http exposing (..)
import Task exposing (..)

import Shared exposing (..)

post : Json.Decoder value -> ServerUrl -> SessionId -> String -> Http.Body -> Task Error value
post decoder serverUrl sessionId path body =
    let request =
        { verb = "POST"
        , headers = [ ("Origin", "http://localhost")
                    , ("Access-Control-Request-Method", "POST")
                    , ("Access-Control-Request-Headers", "Content-Type,Origin,SessionID")
                    , ("Content-Type", "application/json")
                    , ("SessionID", Maybe.withDefault "" sessionId)  ]
        , url = serverUrl ++ "/" ++ path
        , body = body
        }
    in
        fromJson decoder (send defaultSettings request)