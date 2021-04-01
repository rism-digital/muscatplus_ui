module Search.DataTypes exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Device)
import Http
import Language exposing (Language, LanguageMap)
import Shared.DataTypes exposing (RecordType)
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


type ApiResponse
    = Loading
    | Response SearchResponse
    | ApiError
    | NoResponseToShow


{-|

    A filter represents a selected filter query; The values are the
    field name and the value, e.g., "Filter type source". This will then
    get converted to a list of URL parameters, `fq=type:source`.

-}
type Filter
    = Filter String String


type alias SearchResponse =
    { id : String
    , items : List SearchResult
    , view : SearchPagination
    , facets : List Facet
    }


type alias SearchQueryArgs =
    { query : Maybe String
    , filters : List Filter
    , sort : Maybe String
    , page : Int
    }


type alias SearchPagination =
    { next : Maybe String
    , previous : Maybe String
    , first : String
    , last : Maybe String
    , totalPages : Int
    }


type alias SearchResult =
    { id : String
    , label : LanguageMap
    , type_ : RecordType
    , typeLabel : LanguageMap
    }


type alias FacetList =
    { items : List Facet
    }


type alias Facet =
    { alias : String
    , label : LanguageMap
    , expanded : Bool -- facet is showing more than 10 items
    , items : List FacetItem
    }


{-|

    FacetItem is a facet name, a query value, a label (language map),
    and the count of documents in the response.

    E.g.,

    FacetItem "source" {'none': {'some label'}} 123

-}
type FacetItem
    = FacetItem String LanguageMap Int


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
