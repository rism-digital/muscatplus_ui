module Page.RecordTypes.Search exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, andThen, bool, float, int, list, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import List.Extra as LE
import Page.RecordTypes exposing (RecordType(..))
import Page.RecordTypes.Incipit exposing (RenderedIncipit, renderedIncipitDecoder)
import Page.RecordTypes.Shared exposing (LabelBooleanValue, LabelNumericValue, LabelValue, labelNumericValueDecoder, labelValueDecoder, languageMapLabelDecoder, typeDecoder)
import Page.RecordTypes.Source exposing (PartOfSectionBody, partOfSectionBodyDecoder)


type alias SearchBody =
    { id : String
    , totalItems : Int
    , items : List SearchResult
    , pagination : SearchPagination
    , facets : Facets
    , modes : Maybe ModeFacet
    , sorts : List SortData
    }


toFacets : { a | facets : Facets } -> Facets
toFacets body =
    body.facets


setFacets : Facets -> { a | facets : Facets } -> { a | facets : Facets }
setFacets newFacets oldRecord =
    { oldRecord | facets = newFacets }


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
    | IncipitFlags IncipitResultFlags


type alias SourceResultFlags =
    { hasDigitization : Bool
    , hasIIIFManifest : Bool
    , isContentsRecord : Bool
    , isCollectionRecord : Bool
    , hasIncipits : Bool
    , numberOfExemplars : Int
    }


type alias PersonResultFlags =
    { numberOfSources : Int
    }


type alias InstitutionResultFlags =
    { numberOfSources : Int
    }


type alias IncipitResultFlags =
    { highlightedResult : Maybe (List RenderedIncipit)
    }


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
    | Select
    | Notation
    | Query_
    | UnknownFacetType


type FacetData
    = ToggleFacetData ToggleFacet
    | RangeFacetData RangeFacet
    | SelectFacetData SelectFacet
    | NotationFacetData NotationFacet
    | QueryFacetData QueryFacet


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


type alias SelectFacet =
    { alias : String
    , label : LanguageMap
    , items : List FacetItem
    , behaviours : FacetBehaviourOptions
    , defaultSort : FacetSorts
    }


toSelectFacetItems : { a | items : List FacetItem } -> List FacetItem
toSelectFacetItems facetBlock =
    facetBlock.items


setSelectFacetItems : List FacetItem -> { a | items : List FacetItem } -> { a | items : List FacetItem }
setSelectFacetItems newItems oldRecord =
    { oldRecord | items = newItems }


type alias NotationFacet =
    { alias : String
    , label : LanguageMap
    }


type alias QueryFacet =
    { alias : String
    , label : LanguageMap
    , behaviours : FacetBehaviourOptions
    , suggestions : String
    }


toBehaviours : { a | behaviours : FacetBehaviourOptions } -> FacetBehaviourOptions
toBehaviours facet =
    facet.behaviours


type FacetBehaviours
    = FacetBehaviourIntersection
    | FacetBehaviourUnion


facetBehaviourOptions : List ( String, FacetBehaviours )
facetBehaviourOptions =
    [ ( "union", FacetBehaviourUnion )
    , ( "intersection", FacetBehaviourIntersection )
    ]


{-|

    Returns a Facet Behaviour from a given string

-}
parseStringToFacetBehaviour : String -> FacetBehaviours
parseStringToFacetBehaviour inp =
    Dict.fromList facetBehaviourOptions
        |> Dict.get inp
        |> Maybe.withDefault FacetBehaviourIntersection


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


type alias FacetBehaviourOptions =
    { label : LanguageMap
    , items : List FacetOptionsLabelValue
    , default : FacetBehaviours
    , current : FacetBehaviours
    }


toCurrentBehaviour : { a | current : FacetBehaviours } -> FacetBehaviours
toCurrentBehaviour options =
    options.current


toBehaviourItems : { a | items : List FacetOptionsLabelValue } -> List FacetOptionsLabelValue
toBehaviourItems options =
    options.items


{-|

    The default sort order is set by the server

-}
type FacetSorts
    = FacetSortCount
    | FacetSortAlpha


facetSortOptions : List ( String, FacetSorts )
facetSortOptions =
    [ ( "alpha", FacetSortAlpha )
    , ( "count", FacetSortCount )
    ]


{-|

    Returns a Facet Behaviour from a given string

-}
parseStringToFacetSort : String -> FacetSorts
parseStringToFacetSort inp =
    Dict.fromList facetSortOptions
        |> Dict.get inp
        |> Maybe.withDefault FacetSortCount


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


toCurrentSort : { a | current : FacetSorts } -> FacetSorts
toCurrentSort options =
    options.current


toggleFacetSorts : FacetSorts -> FacetSorts
toggleFacetSorts oldValue =
    case oldValue of
        FacetSortCount ->
            FacetSortAlpha

        FacetSortAlpha ->
            FacetSortCount


type alias FacetOptionsLabelValue =
    { label : LanguageMap
    , value : FacetBehaviours
    }


type alias SortData =
    { alias : String
    , label : LanguageMap
    }


{-|

    FacetItem is a a query value, a label (language map),
    and the count of documents in the response.

    E.g.,

    FacetItem "source" {'none': {'some label'}} 123

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
        |> required "sorts" (Decode.list searchSortsDecoder)


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
        , Decode.map (\r -> IncipitFlags r) incipitResultFlagsDecoder
        ]


sourceResultFlagsDecoder : Decoder SourceResultFlags
sourceResultFlagsDecoder =
    Decode.succeed SourceResultFlags
        |> optional "hasDigitization" bool False
        |> optional "hasIIIFManifest" bool False
        |> optional "isContentsRecord" bool False
        |> optional "isCollectionRecord" bool False
        |> optional "hasIncipits" bool False
        |> required "numberOfExemplars" int


personResultFlagsDecoder : Decoder PersonResultFlags
personResultFlagsDecoder =
    Decode.succeed PersonResultFlags
        |> required "numberOfSources" int


institutionResultFlagsDecoder : Decoder InstitutionResultFlags
institutionResultFlagsDecoder =
    Decode.succeed InstitutionResultFlags
        |> required "numberOfSources" int


incipitResultFlagsDecoder : Decoder IncipitResultFlags
incipitResultFlagsDecoder =
    Decode.succeed IncipitResultFlags
        |> optional "highlightedResult" (Decode.maybe (list renderedIncipitDecoder)) Nothing


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

        Select ->
            Decode.map (\r -> SelectFacetData r) selectFacetDecoder

        Notation ->
            Decode.map (\r -> NotationFacetData r) notationFacetDecoder

        Query_ ->
            Decode.map (\r -> QueryFacetData r) queryFacetDecoder

        UnknownFacetType ->
            Decode.fail ("Unknown facet type " ++ typeValue)


facetTypeFromJsonType : String -> FacetType
facetTypeFromJsonType facetType =
    case facetType of
        "rism:ToggleFacet" ->
            Toggle

        "rism:SelectFacet" ->
            Select

        "rism:RangeFacet" ->
            Range

        "rism:NotationFacet" ->
            Notation

        "rism:QueryFacet" ->
            Query_

        _ ->
            UnknownFacetType


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


selectFacetDecoder : Decoder SelectFacet
selectFacetDecoder =
    Decode.succeed SelectFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (Decode.list facetItemDecoder)
        |> required "behaviours" facetBehaviourOptionsDecoder
        |> required "defaultSort" facetSortDecoder


notationFacetDecoder : Decoder NotationFacet
notationFacetDecoder =
    Decode.succeed NotationFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder


queryFacetDecoder : Decoder QueryFacet
queryFacetDecoder =
    Decode.succeed QueryFacet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "behaviours" facetBehaviourOptionsDecoder
        |> required "suggestions" string


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


facetBehaviourOptionsDecoder : Decoder FacetBehaviourOptions
facetBehaviourOptionsDecoder =
    Decode.succeed FacetBehaviourOptions
        |> required "label" languageMapLabelDecoder
        |> required "items" (list facetOptionsLabelValueDecoder)
        |> required "default" facetBehavioursDecoder
        |> required "current" facetBehavioursDecoder


facetBehavioursDecoder : Decoder FacetBehaviours
facetBehavioursDecoder =
    Decode.string
        |> Decode.andThen
            (\str -> Decode.succeed (parseStringToFacetBehaviour str))


facetSortDecoder : Decoder FacetSorts
facetSortDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "count" ->
                        Decode.succeed FacetSortCount

                    "alpha" ->
                        Decode.succeed FacetSortAlpha

                    _ ->
                        Decode.fail ("Unknown value " ++ str ++ " for facet sort")
            )


facetOptionsLabelValueDecoder : Decoder FacetOptionsLabelValue
facetOptionsLabelValueDecoder =
    Decode.succeed FacetOptionsLabelValue
        |> required "label" languageMapLabelDecoder
        |> required "value" facetBehavioursDecoder


searchSortsDecoder : Decoder SortData
searchSortsDecoder =
    Decode.succeed SortData
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
