module Page.Route exposing (Route(..), parseUrl, setRoute, setUrl)

import Page.Keyboard.Model exposing (KeyboardQuery)
import Page.Keyboard.Query exposing (notationParamParser)
import Page.Query exposing (FrontQueryArgs, QueryArgs, frontQueryParamsParser, queryParamsParser)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>), s)


type Route
    = FrontPageRoute FrontQueryArgs
    | SearchPageRoute QueryArgs KeyboardQuery
    | SourcePageRoute Int
    | PersonPageRoute Int
    | PersonSourcePageRoute Int QueryArgs
    | InstitutionPageRoute Int
    | InstitutionSourcePageRoute Int QueryArgs
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
        [ P.map FrontPageRoute (P.top <?> frontQueryParamsParser)
        , P.map SearchPageRoute (s "search" <?> queryParamsParser <?> notationParamParser)
        , P.map SourcePageRoute (s "sources" </> P.int)
        , P.map PersonPageRoute (s "people" </> P.int)
        , P.map PersonSourcePageRoute (s "people" </> P.int </> s "sources" <?> queryParamsParser)
        , P.map InstitutionPageRoute (s "institutions" </> P.int)
        , P.map InstitutionSourcePageRoute (s "institutions" </> P.int </> s "sources" <?> queryParamsParser)
        , P.map PlacePageRoute (s "places" </> P.int)
        , P.map FestivalPageRoute (s "festivals" </> P.int)
        , P.map SubjectPageRoute (s "subjects" </> P.int)
        ]


setRoute : Route -> { a | route : Route } -> { a | route : Route }
setRoute newRoute oldRecord =
    { oldRecord | route = newRoute }


setUrl : Url -> { a | url : Url } -> { a | url : Url }
setUrl newUrl oldRecord =
    { oldRecord | url = newUrl }
