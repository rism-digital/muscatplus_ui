module Page.RecordTypes.Search exposing
    ( FacetBehaviourOptions
    , FacetBehaviours(..)
    , FacetData(..)
    , FacetItem(..)
    , FacetNotationOptions
    , FacetOptionsLabelValue
    , FacetSorts(..)
    , FacetType(..)
    , Facets
    , IncipitResultBody
    , IncipitResultFlags
    , InstitutionResultBody
    , InstitutionResultFlags
    , ModeFacet
    , NotationFacet
    , NotationQueryOptions
    , PersonResultBody
    , PersonResultFlags
    , QueryFacet
    , RangeFacet
    , RangeFacetValue(..)
    , RangeMinMaxValues
    , SearchBody
    , SearchPagination
    , SearchResult(..)
    , SelectFacet
    , SortData
    , SourceResultBody
    , SourceResultFlags
    , ToggleFacet
    , facetsDecoder
    , modeFacetDecoder
    , parseFacetBehaviourToString
    , parseFacetSortToString
    , parseStringToFacetBehaviour
    , parseStringToFacetSort
    , searchBodyDecoder
    , toBehaviourItems
    , toBehaviours
    , toCurrentBehaviour
    )

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, andThen, bool, dict, float, int, list, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import List.Extra as LE
import Page.RecordTypes.Incipit exposing (RenderedIncipit, renderedIncipitDecoder)
import Page.RecordTypes.Shared
    exposing
        ( FacetAlias
        , LabelNumericValue
        , LabelStringValue
        , LabelValue
        , labelNumericValueDecoder
        , labelStringValueDecoder
        , labelValueDecoder
        , languageMapLabelDecoder
        )
import Page.RecordTypes.Source exposing (PartOfSectionBody, partOfSectionBodyDecoder)


type alias FacetBehaviourOptions =
    { label : LanguageMap
    , items : List FacetOptionsLabelValue
    , default : FacetBehaviours
    , current : FacetBehaviours
    }


type FacetBehaviours
    = FacetBehaviourIntersection
    | FacetBehaviourUnion


type FacetData
    = ToggleFacetData ToggleFacet
    | RangeFacetData RangeFacet
    | SelectFacetData SelectFacet
    | NotationFacetData NotationFacet
    | QueryFacetData QueryFacet


{-|

    FacetItem is a a query value, a label (language map),
    and the count of documents in the response.

    E.g.,

    FacetItem "source" {'none': {'some label'}} 123

-}
type FacetItem
    = FacetItem String LanguageMap Float


type alias FacetNotationOptions =
    { clef : NotationQueryOptions
    , keysig : NotationQueryOptions
    , timesig : NotationQueryOptions
    }


type alias FacetOptionsLabelValue =
    { label : LanguageMap
    , value : FacetBehaviours
    }


{-|

    The default sort order is set by the server

-}
type FacetSorts
    = FacetSortCount
    | FacetSortAlpha


type FacetType
    = Range
    | Toggle
    | Select
    | Notation
    | Query_
    | UnknownFacetType


type alias Facets =
    Dict FacetAlias FacetData


type alias IncipitResultBody =
    { id : String
    , label : LanguageMap
    , summary : Maybe (Dict String LabelValue)
    , renderedIncipits : Maybe (List RenderedIncipit)
    }


type alias IncipitResultFlags =
    {}


type alias InstitutionResultBody =
    { id : String
    , label : LanguageMap
    , summary : Maybe (Dict String LabelValue)
    }


type alias InstitutionResultFlags =
    { numberOfSources : Int
    }


type alias ModeFacet =
    { alias : String
    , label : LanguageMap
    , items : List FacetItem
    }


type alias NotationFacet =
    { alias : String
    , label : LanguageMap
    , queryModes : NotationQueryOptions
    , notationOptions : FacetNotationOptions
    }


type alias NotationQueryOptions =
    { label : LanguageMap
    , query : String
    , options : List LabelStringValue
    }


type alias PersonResultBody =
    { id : String
    , label : LanguageMap
    , summary : Maybe (Dict String LabelValue)
    }


type alias PersonResultFlags =
    { numberOfSources : Int
    }


type alias QueryFacet =
    { alias : String
    , label : LanguageMap
    , behaviours : FacetBehaviourOptions
    , suggestions : String
    }


type alias RangeFacet =
    { alias : String
    , label : LanguageMap
    , range : RangeMinMaxValues
    }


type RangeFacetValue
    = LowerRangeValue
    | UpperRangeValue


type alias RangeMinMaxValues =
    { lower : LabelNumericValue
    , upper : LabelNumericValue
    , min : LabelNumericValue
    , max : LabelNumericValue
    }


type alias SearchBody =
    { id : String
    , totalItems : Int
    , items : List SearchResult
    , pagination : SearchPagination
    , facets : Facets
    , modes : Maybe ModeFacet
    , sorts : List SortData
    , pageSizes : List String
    }


type alias SearchPagination =
    { next : Maybe String
    , previous : Maybe String
    , first : String
    , last : Maybe String
    , totalPages : Int
    , thisPage : Int
    }


type SearchResult
    = SourceResult SourceResultBody
    | PersonResult PersonResultBody
    | InstitutionResult InstitutionResultBody
    | IncipitResult IncipitResultBody


type alias SelectFacet =
    { alias : String
    , label : LanguageMap
    , items : List FacetItem
    , behaviours : FacetBehaviourOptions
    , defaultSort : FacetSorts
    }


type alias SortData =
    { alias : String
    , label : LanguageMap
    }


type alias SourceResultBody =
    { id : String
    , label : LanguageMap
    , partOf : Maybe PartOfSectionBody
    , summary : Maybe (Dict String LabelValue)
    , flags : Maybe SourceResultFlags
    }


type alias SourceResultFlags =
    { hasDigitization : Bool
    , hasIIIFManifest : Bool
    , isContentsRecord : Bool
    , isCollectionRecord : Bool
    , hasIncipits : Bool
    }


type alias ToggleFacet =
    { alias : String
    , label : LanguageMap
    , value : String
    }


facetBehaviourOptions : List ( String, FacetBehaviours )
facetBehaviourOptions =
    [ ( "union", FacetBehaviourUnion )
    , ( "intersection", FacetBehaviourIntersection )
    ]


facetBehaviourOptionsDecoder : Decoder FacetBehaviourOptions
facetBehaviourOptionsDecoder =
    Decode.succeed FacetBehaviourOptions
        |> required "label" languageMapLabelDecoder
        |> required "items" (list facetOptionsLabelValueDecoder)
        |> required "default" facetBehavioursDecoder
        |> required "current" facetBehavioursDecoder


facetBehavioursDecoder : Decoder FacetBehaviours
facetBehavioursDecoder =
    string
        |> andThen
            (\str -> Decode.succeed (parseStringToFacetBehaviour str))


facetItemDecoder : Decoder FacetItem
facetItemDecoder =
    Decode.succeed FacetItem
        |> required "value" string
        |> required "label" languageMapLabelDecoder
        |> required "count" float


facetNotationOptionsDecoder : Decoder FacetNotationOptions
facetNotationOptionsDecoder =
    Decode.succeed FacetNotationOptions
        |> required "clef" notationQueryOptionsDecoder
        |> required "keysig" notationQueryOptionsDecoder
        |> required "timesig" notationQueryOptionsDecoder


facetOptionsLabelValueDecoder : Decoder FacetOptionsLabelValue
facetOptionsLabelValueDecoder =
    Decode.succeed FacetOptionsLabelValue
        |> required "label" languageMapLabelDecoder
        |> required "value" facetBehavioursDecoder


facetResponseConverter : String -> Decoder FacetData
facetResponseConverter typeValue =
    case facetTypeFromJsonType typeValue of
        Range ->
            Decode.map (\r -> RangeFacetData r) rangeFacetDecoder

        Toggle ->
            Decode.map (\r -> ToggleFacetData r) toggleFacetDecoder

        Select ->
            Decode.map (\r -> SelectFacetData r) selectFacetDecoder

        Notation ->
            Decode.map (\r -> NotationFacetData r) notationFacetDecoder

        Query_ ->
            Decode.map (\r -> QueryFacetData r) queryFacetDecoder

        UnknownFacetType ->
            Decode.fail ("Unknown facet type " ++ typeValue)


facetResponseDecoder : Decoder FacetData
facetResponseDecoder =
    Decode.field "type" string
        |> andThen facetResponseConverter


facetSortDecoder : Decoder FacetSorts
facetSortDecoder =
    string
        |> andThen
            (\str ->
                case str of
                    "alpha" ->
                        Decode.succeed FacetSortAlpha

                    "count" ->
                        Decode.succeed FacetSortCount

                    _ ->
                        Decode.fail ("Unknown value " ++ str ++ " for facet sort")
            )


facetSortOptions : List ( String, FacetSorts )
facetSortOptions =
    [ ( "alpha", FacetSortAlpha )
    , ( "count", FacetSortCount )
    ]


facetTypeFromJsonType : String -> FacetType
facetTypeFromJsonType facetType =
    case facetType of
        "rism:NotationFacet" ->
            Notation

        "rism:QueryFacet" ->
            Query_

        "rism:RangeFacet" ->
            Range

        "rism:SelectFacet" ->
            Select

        "rism:ToggleFacet" ->
            Toggle

        _ ->
            UnknownFacetType


facetsDecoder : Decoder Facets
facetsDecoder =
    dict facetResponseDecoder


incipitResultBodyDecoder : Decoder IncipitResultBody
incipitResultBodyDecoder =
    Decode.succeed IncipitResultBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (dict labelValueDecoder)) Nothing
        |> optional "rendered" (Decode.maybe (list renderedIncipitDecoder)) Nothing


institutionResultBodyDecoder : Decoder InstitutionResultBody
institutionResultBodyDecoder =
    Decode.succeed InstitutionResultBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (dict labelValueDecoder)) Nothing


modeFacetDecoder : Decoder ModeFacet
modeFacetDecoder =
    Decode.succeed ModeFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (list facetItemDecoder)


notationFacetDecoder : Decoder NotationFacet
notationFacetDecoder =
    Decode.succeed NotationFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "modes" notationQueryOptionsDecoder
        |> required "options" facetNotationOptionsDecoder


notationQueryOptionsDecoder : Decoder NotationQueryOptions
notationQueryOptionsDecoder =
    Decode.succeed NotationQueryOptions
        |> required "label" languageMapLabelDecoder
        |> required "query" string
        |> required "options" (list labelStringValueDecoder)


parseFacetBehaviourToString : FacetBehaviours -> String
parseFacetBehaviourToString beh =
    LE.findMap
        (\( alias, behaviour ) ->
            if beh == behaviour then
                Just alias

            else
                Nothing
        )
        facetBehaviourOptions
        |> Maybe.withDefault "intersection"


parseFacetSortToString : FacetSorts -> String
parseFacetSortToString beh =
    LE.findMap
        (\( alias, behaviour ) ->
            if beh == behaviour then
                Just alias

            else
                Nothing
        )
        facetSortOptions
        |> Maybe.withDefault "intersection"


{-|

    Returns a Facet Behaviour from a given string

-}
parseStringToFacetBehaviour : String -> FacetBehaviours
parseStringToFacetBehaviour inp =
    Dict.fromList facetBehaviourOptions
        |> Dict.get inp
        |> Maybe.withDefault FacetBehaviourIntersection


{-|

    Returns a Facet Behaviour from a given string

-}
parseStringToFacetSort : String -> FacetSorts
parseStringToFacetSort inp =
    Dict.fromList facetSortOptions
        |> Dict.get inp
        |> Maybe.withDefault FacetSortCount


personResultBodyDecoder : Decoder PersonResultBody
personResultBodyDecoder =
    Decode.succeed PersonResultBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (dict labelValueDecoder)) Nothing


queryFacetDecoder : Decoder QueryFacet
queryFacetDecoder =
    Decode.succeed QueryFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "behaviours" facetBehaviourOptionsDecoder
        |> required "suggestions" string


rangeFacetDecoder : Decoder RangeFacet
rangeFacetDecoder =
    Decode.succeed RangeFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "range" rangeFacetMinMaxDecoder


rangeFacetMinMaxDecoder : Decoder RangeMinMaxValues
rangeFacetMinMaxDecoder =
    Decode.succeed RangeMinMaxValues
        |> required "lower" labelNumericValueDecoder
        |> required "upper" labelNumericValueDecoder
        |> required "min" labelNumericValueDecoder
        |> required "max" labelNumericValueDecoder


searchBodyDecoder : Decoder SearchBody
searchBodyDecoder =
    Decode.succeed SearchBody
        |> required "id" string
        |> required "totalItems" int
        |> optional "items" (list searchResultDecoder) []
        |> required "view" searchPaginationDecoder
        |> optional "facets" facetsDecoder Dict.empty
        |> optional "modes" (Decode.maybe modeFacetDecoder) Nothing
        |> required "sorts" (list searchSortsDecoder)
        |> required "pageSizes" (list string)


searchPaginationDecoder : Decoder SearchPagination
searchPaginationDecoder =
    Decode.succeed SearchPagination
        |> optional "next" (nullable string) Nothing
        |> optional "previous" (nullable string) Nothing
        |> required "first" string
        |> optional "last" (nullable string) Nothing
        |> required "totalPages" int
        |> required "thisPage" int


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    Decode.field "type" string
        |> andThen searchResultTypeDecoder


searchResultTypeDecoder : String -> Decoder SearchResult
searchResultTypeDecoder restype =
    case restype of
        "rism:Incipit" ->
            Decode.map (\r -> IncipitResult r) incipitResultBodyDecoder

        "rism:Institution" ->
            Decode.map (\r -> InstitutionResult r) institutionResultBodyDecoder

        "rism:Person" ->
            Decode.map (\r -> PersonResult r) personResultBodyDecoder

        "rism:Source" ->
            Decode.map (\r -> SourceResult r) sourceResultBodyDecoder

        _ ->
            Decode.fail ("Could not determine result type for " ++ restype)


searchSortsDecoder : Decoder SortData
searchSortsDecoder =
    Decode.succeed SortData
        |> required "alias" string
        |> required "label" languageMapLabelDecoder


selectFacetDecoder : Decoder SelectFacet
selectFacetDecoder =
    Decode.succeed SelectFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (list facetItemDecoder)
        |> required "behaviours" facetBehaviourOptionsDecoder
        |> required "defaultSort" facetSortDecoder


sourceResultBodyDecoder : Decoder SourceResultBody
sourceResultBodyDecoder =
    Decode.succeed SourceResultBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "partOf" (Decode.maybe partOfSectionBodyDecoder) Nothing
        |> optional "summary" (Decode.maybe (dict labelValueDecoder)) Nothing
        |> optional "flags" (Decode.maybe sourceResultFlagsDecoder) Nothing


sourceResultFlagsDecoder : Decoder SourceResultFlags
sourceResultFlagsDecoder =
    Decode.succeed SourceResultFlags
        |> optional "hasDigitization" bool False
        |> optional "hasIIIFManifest" bool False
        |> optional "isContentsRecord" bool False
        |> optional "isCollectionRecord" bool False
        |> optional "hasIncipits" bool False


toBehaviourItems : { a | items : List FacetOptionsLabelValue } -> List FacetOptionsLabelValue
toBehaviourItems options =
    options.items


toBehaviours : { a | behaviours : FacetBehaviourOptions } -> FacetBehaviourOptions
toBehaviours facet =
    facet.behaviours


toCurrentBehaviour : { a | current : FacetBehaviours } -> FacetBehaviours
toCurrentBehaviour options =
    options.current


toggleFacetDecoder : Decoder ToggleFacet
toggleFacetDecoder =
    Decode.succeed ToggleFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "value" string
