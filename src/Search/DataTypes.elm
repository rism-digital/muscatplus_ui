module Search.DataTypes exposing (..)

import Api.Search exposing (ApiResponse(..), SearchQueryArgs, SearchResponse)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Device)
import Http
import Language exposing (Language)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), s)


type Msg
    = ReceivedSearchResponse (Result Http.Error SearchResponse)
    | SearchInput SearchQueryArgs
    | SearchSubmit
    | OnWindowResize Device
    | UrlChange Url
    | UrlRequest UrlRequest
    | LanguageSelectChanged String
    | NoOp


type Route
    = FrontPageRoute
    | SearchPageRoute
    | NotFound


type alias Model =
    { key : Nav.Key
    , url : Url
    , query : SearchQueryArgs
    , response : ApiResponse
    , errorMessage : String
    , viewingDevice : Device
    , language : Language
    , currentRoute : Route
    }


parseUrl : Url -> Route
parseUrl url =
    case P.parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFound


routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map FrontPageRoute P.top
        , P.map SearchPageRoute (s "search")
        ]


routeMatches : Url -> Maybe Route
routeMatches url =
    P.parse routeParser url
