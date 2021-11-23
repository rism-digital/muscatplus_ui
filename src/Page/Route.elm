module Page.Route exposing (Route(..), parseUrl, setRoute, setUrl)

import Page.Query exposing (QueryArgs, queryParamsParser)
import Page.UI.Keyboard.Model exposing (KeyboardQuery)
import Page.UI.Keyboard.Query exposing (notationParamParser)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>), s)


type Route
    = FrontPageRoute
    | SearchPageRoute QueryArgs KeyboardQuery
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
        , P.map SearchPageRoute (s "search" <?> queryParamsParser <?> notationParamParser)
        , P.map SourcePageRoute (s "sources" </> P.int)
        , P.map PersonPageRoute (s "people" </> P.int)
        , P.map InstitutionPageRoute (s "institutions" </> P.int)
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
