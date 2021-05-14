module Page.Model exposing (..)

import Page.Response exposing (ServerData)
import Page.Route exposing (Route)
import Url exposing (Url)


type Response
    = Loading
    | Response ServerData
    | Error String
    | NoResponseToShow


type alias PageModel =
    { response : Response
    , route : Route
    , url : Url
    }
