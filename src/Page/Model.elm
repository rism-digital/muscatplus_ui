module Page.Model exposing (..)

import Page.Query exposing (QueryArgs)
import Page.Response exposing (ServerData)
import Page.Route exposing (Route)
import Url exposing (Url)


type Response
    = Loading
    | Response ServerData
    | Error String
    | NoResponseToShow


type CurrentRecordViewTab
    = DefaultRecordViewTab
    | PersonSourcesRecordSearchTab String
    | InstitutionSourcesRecordSearchTab String


type alias PageSearch =
    { query : QueryArgs }


type alias PageModel =
    { response : Response
    , route : Route
    , url : Url
    , currentTab : CurrentRecordViewTab
    , searchResults : Response
    , searchParams : PageSearch
    }
