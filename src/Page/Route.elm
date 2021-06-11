module Page.Route exposing (Route(..), parseUrl)

import Page.Query exposing (QueryArgs, queryParamsParser)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>), s)


type Route
    = FrontPageRoute
    | SearchPageRoute QueryArgs
    | SourcePageRoute Int
    | PersonPageRoute Int
    | InstitutionPageRoute Int
    | PlacePageRoute Int
    | FestivalPageRoute Int
    | SubjectPageRoute Int
    | NotFoundPageRoute


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
        , P.map SubjectPageRoute (s "subjects" </> P.int)
        ]
