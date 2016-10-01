port module Ports exposing (..)

import Json.Encode as JsonEncode exposing (..)

port mapData : JsonEncode.Value  -> Cmd data
