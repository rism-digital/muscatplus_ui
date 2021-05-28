module Msg exposing (Msg(..))

import Browser exposing (UrlRequest)
import Element exposing (Device)
import Http
import Page.RecordTypes.Search exposing (FacetItem)
import Page.Response exposing (ServerData)
import Url exposing (Url)


type Msg
    = OnWindowResize Device
    | ReceivedServerResponse (Result Http.Error ServerData)
    | ReceivedPreviewResponse (Result Http.Error ServerData)
    | UrlRequest UrlRequest
    | UrlChanged Url
    | SearchSubmit
    | SearchInput String
    | LanguageSelectChanged String
    | FacetChecked String FacetItem Bool
    | ModeSelected String FacetItem Bool
    | PreviewSearchResult String
    | NoOp
