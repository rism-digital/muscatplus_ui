module Routes exposing (..)

import Api.Query exposing (QueryArgs, queryParamsParser)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>), s)


type alias Model =
    { key : Nav.Key
    , url : Url
    , currentRoute : Route
    }


type Message
    = UrlRequest UrlRequest
    | UrlChanged Url


type Route
    = FrontPageRoute
    | SearchPageRoute QueryArgs
    | SourcePageRoute Int
    | PersonPageRoute Int
    | InstitutionPageRoute Int
    | PlacePageRoute Int
    | FestivalPageRoute Int
    | NotFoundPageRoute


init : Url -> Nav.Key -> Model
init initialUrl key =
    let
        route =
            parseUrl initialUrl
    in
    { key = key
    , url = initialUrl
    , currentRoute = route
    }


update : Message -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                newRoute =
                    parseUrl url
            in
            ( { model | url = url, currentRoute = newRoute }, Cmd.none )


parseUrl : Url -> Route
parseUrl url =
    case P.parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFoundPageRoute


routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map FrontPageRoute P.top
        , P.map SearchPageRoute (s "search" <?> queryParamsParser)
        , P.map SourcePageRoute (s "sources" </> P.int)
        , P.map PersonPageRoute (s "people" </> P.int)
        , P.map InstitutionPageRoute (s "institutions" </> P.int)
        , P.map PlacePageRoute (s "places" </> P.int)
        , P.map FestivalPageRoute (s "festivals" </> P.int)
        ]


routeMatches : Url -> Maybe Route
routeMatches url =
    P.parse routeParser url
