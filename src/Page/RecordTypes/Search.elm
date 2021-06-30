module Page.RecordTypes.Search exposing (FacetData(..), FacetItem(..), FilterFacet, ModeFacet, RangeFacet, SearchBody, SearchPagination, SearchResult, SelectorFacet, ToggleFacet, searchBodyDecoder)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, andThen, bool, float, int, list, nullable, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes exposing (RecordType)
import Page.RecordTypes.Shared exposing (LabelBooleanValue, LabelNumericValue, LabelValue, labelNumericValueDecoder, labelValueDecoder, languageMapLabelDecoder, typeDecoder)
import Page.RecordTypes.Source exposing (PartOfSectionBody, partOfSectionBodyDecoder)


type alias SearchBody =
    { id : String
    , totalItems : Int
    , items : List SearchResult
    , pagination : SearchPagination
    , facets : Facets
    , modes : Maybe ModeFacet
    }


type alias SearchResult =
    { id : String
    , label : LanguageMap
    , type_ : RecordType
    , partOf : Maybe PartOfSectionBody
    , summary : Maybe (List LabelValue)
    , flags : Maybe SearchResultFlags
    }


type SearchResultFlags
    = SourceFlags SourceResultFlags
    | PersonFlags PersonResultFlags
    | InstitutionFlags InstitutionResultFlags


type alias SourceResultFlags =
    { hasDigitization : Bool
    , hasIIIFManifest : Bool
    , isContentsRecord : Bool
    , isCollectionRecord : Bool
    , hasIncipits : Bool
    , numberOfExemplars : Int
    }


type alias PersonResultFlags =
    {}


type alias InstitutionResultFlags =
    {}


type alias SearchPagination =
    { next : Maybe String
    , previous : Maybe String
    , first : String
    , last : Maybe String
    , totalPages : Int
    , thisPage : Int
    }


type alias Facets =
    Dict String FacetData


type FacetType
    = Range
    | Toggle
    | Filter
    | Selector


type FacetData
    = ToggleFacetData ToggleFacet
    | RangeFacetData RangeFacet
    | SelectorFacetData SelectorFacet
    | FilterFacetData FilterFacet


type alias ModeFacet =
    { alias : String
    , label : LanguageMap
    , items : List FacetItem
    }


type alias RangeFacet =
    { alias : String
    , label : LanguageMap
    , range : RangeMinMaxValues
    }


type alias RangeMinMaxValues =
    { lower : LabelNumericValue
    , upper : LabelNumericValue
    , min : LabelNumericValue
    , max : LabelNumericValue
    }


type alias ToggleFacet =
    { alias : String
    , label : LanguageMap
    , value : String
    }


type alias SelectorFacet =
    { alias : String
    , label : LanguageMap
    , items : List FacetItem
    }


type alias FilterFacet =
    { alias : String
    , label : LanguageMap
    , items : List FacetItem
    }


{-|

    FacetItem is a facet type, a query value, a label (language map),
    and the count of documents in the response.

    E.g.,

    FacetItem "source" {'none': {'some label'}} 123

    Facet items get converted to Filters when selected, which are what are used to initiate
    changes to the API requests.

-}
type FacetItem
    = FacetItem String LanguageMap Float


searchBodyDecoder : Decoder SearchBody
searchBodyDecoder =
    Decode.succeed SearchBody
        |> required "id" string
        |> required "totalItems" int
        |> optional "items" (Decode.list searchResultDecoder) []
        |> required "view" searchPaginationDecoder
        |> optional "facets" facetsDecoder Dict.empty
        |> optional "modes" (Decode.maybe modeFacetDecoder) Nothing


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    Decode.succeed SearchResult
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "type" typeDecoder
        |> optional "partOf" (Decode.maybe partOfSectionBodyDecoder) Nothing
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "flags" (Decode.maybe searchResultFlagsDecoder) Nothing


searchResultFlagsDecoder : Decoder SearchResultFlags
searchResultFlagsDecoder =
    Decode.oneOf
        [ Decode.map (\r -> SourceFlags r) sourceResultFlagsDecoder
        , Decode.map (\r -> PersonFlags r) personResultFlagsDecoder
        , Decode.map (\r -> InstitutionFlags r) institutionResultFlagsDecoder
        ]


sourceResultFlagsDecoder : Decoder SourceResultFlags
sourceResultFlagsDecoder =
    Decode.succeed SourceResultFlags
        |> optional "hasDigitization" bool False
        |> optional "hasIIIFManifest" bool False
        |> optional "isContentsRecord" bool False
        |> optional "isCollectionRecord" bool False
        |> optional "hasIncipits" bool False
        |> optional "numberOfExemplars" int 0


personResultFlagsDecoder : Decoder PersonResultFlags
personResultFlagsDecoder =
    Decode.succeed PersonResultFlags


institutionResultFlagsDecoder : Decoder InstitutionResultFlags
institutionResultFlagsDecoder =
    Decode.succeed InstitutionResultFlags


searchPaginationDecoder : Decoder SearchPagination
searchPaginationDecoder =
    Decode.succeed SearchPagination
        |> optional "next" (nullable string) Nothing
        |> optional "previous" (nullable string) Nothing
        |> required "first" string
        |> optional "last" (nullable string) Nothing
        |> required "totalPages" int
        |> required "thisPage" int


facetsDecoder : Decoder Facets
facetsDecoder =
    Decode.dict facetResponseDecoder


facetResponseDecoder : Decoder FacetData
facetResponseDecoder =
    Decode.field "type" string
        |> andThen facetResponseConverter


facetResponseConverter : String -> Decoder FacetData
facetResponseConverter typeValue =
    case facetTypeFromJsonType typeValue of
        Toggle ->
            Decode.map (\r -> ToggleFacetData r) toggleFacetDecoder

        Range ->
            Decode.map (\r -> RangeFacetData r) rangeFacetDecoder

        Filter ->
            Decode.map (\r -> FilterFacetData r) filterFacetDecoder

        Selector ->
            Decode.map (\r -> SelectorFacetData r) selectorFacetDecoder


facetTypeFromJsonType : String -> FacetType
facetTypeFromJsonType facetType =
    case facetType of
        "rism:ToggleFacet" ->
            Toggle

        "rism:SelectorFacet" ->
            Selector

        "rism:RangeFacet" ->
            Range

        "rism:FilterFacet" ->
            Filter

        _ ->
            Filter


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


toggleFacetDecoder : Decoder ToggleFacet
toggleFacetDecoder =
    Decode.succeed ToggleFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "value" string


selectorFacetDecoder : Decoder SelectorFacet
selectorFacetDecoder =
    Decode.succeed SelectorFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (Decode.list facetItemDecoder)


filterFacetDecoder : Decoder FilterFacet
filterFacetDecoder =
    Decode.succeed FilterFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (Decode.list facetItemDecoder)


modeFacetDecoder : Decoder ModeFacet
modeFacetDecoder =
    Decode.succeed ModeFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (Decode.list facetItemDecoder)


facetItemDecoder : Decoder FacetItem
facetItemDecoder =
    Decode.succeed FacetItem
        |> required "value" string
        |> required "label" languageMapLabelDecoder
        |> required "count" float
