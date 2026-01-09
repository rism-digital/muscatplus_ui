module Page.Route exposing (Route(..), baseRecordPathFromRoute, isMEIDownloadRoute, isPNGDownloadRoute, parseUrl, routeToResultMode, setRoute, setUrl)

import Page.Keyboard.Model exposing (KeyboardQuery)
import Page.Keyboard.Query exposing (notationParamParser)
import Page.Query exposing (FrontQueryArgs, QueryArgs, frontQueryParamsParser, queryParamsParser)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>), s)


type Route
    = FrontPageRoute FrontQueryArgs
    | SearchPageRoute QueryArgs KeyboardQuery
    | SourcePageRoute Int
    | SourceContentsPageRoute Int QueryArgs
    | SourceHoldingsPageRoute Int Int
    | PersonPageRoute Int
    | PersonSourcePageRoute Int QueryArgs
    | InstitutionPageRoute Int
    | InstitutionSourcePageRoute Int QueryArgs
    | PublicationPageRoute Int
    | PublicationWorksPageRoute Int QueryArgs
    | PublicationsListPageRoute
    | WorkPageRoute Int
    | WorkSourcePageRoute Int QueryArgs
      --| PlacePageRoute Int
    | AboutPageRoute
    | HelpPageRoute
    | OptionsPageRoute
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
        , P.map SourceHoldingsPageRoute (s "sources" </> P.int </> s "holdings" </> P.int)
        , P.map PersonPageRoute (s "people" </> P.int)
        , P.map PersonSourcePageRoute (s "people" </> P.int </> s "sources" <?> queryParamsParser)
        , P.map InstitutionPageRoute (s "institutions" </> P.int)
        , P.map InstitutionSourcePageRoute (s "institutions" </> P.int </> s "sources" <?> queryParamsParser)
        , P.map PublicationPageRoute (s "publications" </> P.int)
        , P.map PublicationWorksPageRoute (s "publications" </> P.int </> s "works" <?> queryParamsParser)
        , P.map PublicationsListPageRoute (s "publications")
        , P.map WorkPageRoute (s "works" </> P.int)
        , P.map WorkSourcePageRoute (s "works" </> P.int </> s "sources" <?> queryParamsParser)
        , P.map AboutPageRoute (s "about")
        , P.map HelpPageRoute (s "about") </> s "help"
        , P.map OptionsPageRoute (s "about") </> s "options"
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


baseRecordPathFromRoute : Route -> String
baseRecordPathFromRoute route =
    case route of
        FrontPageRoute _ ->
            "/"

        SearchPageRoute _ _ ->
            "/search"

        SourcePageRoute rid ->
            "/sources/" ++ String.fromInt rid

        SourceContentsPageRoute rid _ ->
            "/sources/" ++ String.fromInt rid

        SourceHoldingsPageRoute rid _ ->
            "/sources/" ++ String.fromInt rid

        PersonPageRoute pid ->
            "/people/" ++ String.fromInt pid

        PersonSourcePageRoute pid _ ->
            "/people/" ++ String.fromInt pid

        InstitutionPageRoute iid ->
            "/institutions/" ++ String.fromInt iid

        InstitutionSourcePageRoute iid _ ->
            "/institutions/" ++ String.fromInt iid

        PublicationPageRoute pid ->
            "/publications/" ++ String.fromInt pid

        PublicationWorksPageRoute pid _ ->
            "/publications/" ++ String.fromInt pid

        PublicationsListPageRoute ->
            "/publications/"

        WorkPageRoute wid ->
            "/works/" ++ String.fromInt wid

        WorkSourcePageRoute wid _ ->
            "/works/" ++ String.fromInt wid

        AboutPageRoute ->
            "/about/"

        HelpPageRoute ->
            "/about/help/"

        OptionsPageRoute ->
            "/about/options/"

        NotFoundPageRoute ->
            "/does-not-exist"


routeToResultMode : Route -> ResultMode
routeToResultMode route =
    case route of
        SourcePageRoute _ ->
            SourcesMode

        SourceContentsPageRoute _ _ ->
            SourcesMode

        SourceHoldingsPageRoute _ _ ->
            EmptyMode

        PersonPageRoute _ ->
            SourcesMode

        PersonSourcePageRoute _ _ ->
            SourcesMode

        InstitutionPageRoute _ ->
            SourcesMode

        InstitutionSourcePageRoute _ _ ->
            SourcesMode

        PublicationWorksPageRoute _ _ ->
            WorkMode

        WorkSourcePageRoute _ _ ->
            SourcesMode

        FrontPageRoute qargs ->
            qargs.mode

        SearchPageRoute qargs _ ->
            qargs.mode

        _ ->
            EmptyMode
