module Search.DataTypes exposing (..)

import Api.Search exposing (ApiResponse(..), FacetItem(..), Filter(..), SearchQueryArgs, SearchResponse)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Device)
import Http
import Language exposing (Language)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), (<?>), s)
import Url.Parser.Query as Q


type Msg
    = ReceivedSearchResponse (Result Http.Error SearchResponse)
    | SearchInput String
    | SearchSubmit
    | OnWindowResize Device
    | UrlChange Url
    | UrlRequest UrlRequest
    | LanguageSelectChanged String
    | FacetChecked String FacetItem Bool
    | NoOp


type Route
    = FrontPageRoute
    | SearchPageRoute SearchQueryArgs
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
    , selectedFacets : List FacetItem
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
        , P.map SearchPageRoute (s "search" <?> queryParamsParser)
        ]


queryParamsParser : Q.Parser SearchQueryArgs
queryParamsParser =
    Q.map4 SearchQueryArgs (Q.string "q") fqParamParser (Q.string "sort") pageParamParser


fqParamParser : Q.Parser (List Filter)
fqParamParser =
    Q.custom "fq" (\a -> filterQueryStringToFilter a)


filterQueryStringToFilter : List String -> List Filter
filterQueryStringToFilter fqlist =
    -- discards any filters that do not conform to the expected values
    -- TODO: Convert this to a parser that can handle colons in the 'values'
    List.concat
        (List.map
            (\a ->
                case String.split ":" a of
                    [ field, value ] ->
                        [ Filter field value ]

                    _ ->
                        []
            )
            fqlist
        )


pageParamParser : Q.Parser Int
pageParamParser =
    -- returns 1 if the page parameter cannot be parsed to an int.
    Q.custom "page"
        (\stringList ->
            case stringList of
                [ str ] ->
                    Maybe.withDefault 1 (String.toInt str)

                _ ->
                    1
        )


routeMatches : Url -> Maybe Route
routeMatches url =
    P.parse routeParser url


convertFacetToFilter : String -> FacetItem -> Filter
convertFacetToFilter name facet =
    let
        (FacetItem qval label count) =
            facet
    in
    Filter name qval
