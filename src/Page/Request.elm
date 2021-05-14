module Page.Request exposing (..)

import Msg exposing (Msg)
import Page.Decoders exposing (recordResponseDecoder)
import Request exposing (createRequest)


createRequestWithDecoder : String -> Cmd Msg
createRequestWithDecoder url =
    createRequest Msg.ReceivedServerResponse recordResponseDecoder url
