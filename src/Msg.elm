module Msg exposing (Msg(..))

import Browser exposing (UrlRequest)
import Element exposing (Device)
import Http
import Page.Response exposing (ServerData)
import Url exposing (Url)


type Msg
    = OnWindowResize Device
    | ReceivedServerResponse (Result Http.Error ServerData)
    | UrlRequest UrlRequest
    | UrlChanged Url
    | SearchSubmit
    | SearchInput String
    | LanguageSelectChanged String
    | NoOp
