module Page.Route exposing (Route(..), isMEIDownloadRoute, isPNGDownloadRoute, parseUrl, setRoute, setUrl)

import Page.Keyboard.Model exposing (KeyboardQuery)
import Page.Keyboard.Query exposing (notationParamParser)
import Page.Query exposing (FrontQueryArgs, QueryArgs, frontQueryParamsParser, queryParamsParser)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>), s)


type Route
    = FrontPageRoute FrontQueryArgs
    | SearchPageRoute QueryArgs KeyboardQuery
    | SourcePageRoute Int
    | SourceContentsPageRoute Int QueryArgs
    | PersonPageRoute Int
    | PersonSourcePageRoute Int QueryArgs
    | InstitutionPageRoute Int
    | InstitutionSourcePageRoute Int QueryArgs
      --| PlacePageRoute Int
    | AboutPageRoute
    | NotFoundPageRoute


parseUrl : Url -> Route
parseUrl url =
    P.parse routeParser url
        |> Maybe.withDefault NotFoundPageRoute


setRoute : Route -> { a | route : Route } -> { a | route : Route }
setRoute newRoute oldRecord =
    { oldRecord | route = newRoute }


setUrl : Url -> { a | url : Url } -> { a | url : Url }
setUrl newUrl oldRecord =
    { oldRecord | url = newUrl }


routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map FrontPageRoute (P.top <?> frontQueryParamsParser)
        , P.map SearchPageRoute (s "search" <?> queryParamsParser <?> notationParamParser)
        , P.map SourcePageRoute (s "sources" </> P.int)
        , P.map SourceContentsPageRoute (s "sources" </> P.int </> s "contents" <?> queryParamsParser)
        , P.map PersonPageRoute (s "people" </> P.int)
        , P.map PersonSourcePageRoute (s "people" </> P.int </> s "sources" <?> queryParamsParser)
        , P.map InstitutionPageRoute (s "institutions" </> P.int)
        , P.map InstitutionSourcePageRoute (s "institutions" </> P.int </> s "sources" <?> queryParamsParser)
        , P.map AboutPageRoute (s "about")
        ]


meiDownloadRouteParser : P.Parser (Bool -> a) a
meiDownloadRouteParser =
    P.map (\_ _ -> True) (s "sources" </> P.int </> s "incipits" </> P.string </> s "mei")


pngDownloadRouteParser : P.Parser (Bool -> a) a
pngDownloadRouteParser =
    P.map (\_ _ -> True) (s "sources" </> P.int </> s "incipits" </> P.string </> s "png")


isMEIDownloadRoute : Url -> Bool
isMEIDownloadRoute url =
    P.parse meiDownloadRouteParser url
        |> Maybe.withDefault False


isPNGDownloadRoute : Url -> Bool
isPNGDownloadRoute url =
    P.parse pngDownloadRouteParser url
        |> Maybe.withDefault False
