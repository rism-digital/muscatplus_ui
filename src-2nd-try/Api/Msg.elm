module Api.Msg exposing (..)

import Api.Response exposing (ServerResponse)
import Http


type Message
    = ReceivedServerResponse (Result Http.Error ServerResponse)
