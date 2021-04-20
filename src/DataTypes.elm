module DataTypes exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Device)
import Http
import Language exposing (Language, LanguageMap)
import Url exposing (Url)


type Msg
    = ReceivedServerResponse (Result Http.Error ServerResponse)
    | OnWindowResize Device
    | UrlRequest UrlRequest
    | UrlChanged Url
    | LanguageSelectChanged String
    | SearchInput String
    | SearchSubmit
    | FacetChecked String FacetItem Bool
    | ModeChecked String FacetItem Bool
    | ToggleExpandFacet String
    | NoOp


type alias Model =
    { key : Nav.Key
    , url : Url
    , response : ApiResponse
    , activeSearch : ActiveSearch
    , errorMessage : String
    , language : Language
    , viewingDevice : Device
    , currentRoute : Route
    }


type alias ActiveSearch =
    { query : SearchQueryArgs
    , selectedFilters : List Filter
    , selectedMode : ResultMode
    , expandedFacets : List String
    }


type Route
    = FrontPageRoute
    | SearchPageRoute SearchQueryArgs
    | SourceRoute Int
    | PersonRoute Int
    | InstitutionRoute Int
    | PlaceRoute Int
    | FestivalRoute Int
    | NotFound


type alias Flags =
    { locale : String
    , windowWidth : Int
    , windowHeight : Int
    }


type ApiResponse
    = Loading
    | Response ServerResponse
    | ApiError
    | NoResponseToShow


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Incipit
    | Festival
    | CollectionSearchResult
    | Unknown


type IncipitFormat
    = RenderedSVG
    | RenderedMIDI
    | UnknownFormat


type ServerResponse
    = SourceResponse SourceBody
    | PersonResponse PersonBody
    | InstitutionResponse InstitutionBody
    | PlaceResponse PlaceBody
    | FestivalResponse FestivalBody
    | SearchResponse SearchBody


{-|

    A filter represents a selected filter query; The values are the
    field name and the value, e.g., "Filter type source". This will then
    get converted to a list of URL parameters, `fq=type:source`.

-}
type Filter
    = Filter String String


type ResultMode
    = Sources
    | People
    | Institutions
    | Incipits
    | LiturgicalFestivals


defaultModeFilter : ResultMode
defaultModeFilter =
    Sources


resultModeOptions : List ( String, ResultMode )
resultModeOptions =
    [ ( "sources", Sources )
    , ( "people", People )
    , ( "institutions", Institutions )
    , ( "incipits", Incipits )
    , ( "festivals", LiturgicalFestivals )
    ]


{-|

    Takes a string and parses it to a result mode type. If one is not found
    then it assumes 'everything' is the default.

-}
parseStringToResultMode : String -> ResultMode
parseStringToResultMode string =
    List.filter (\( str, _ ) -> str == string) resultModeOptions
        |> List.head
        |> Maybe.withDefault ( "sources", Sources )
        |> Tuple.second


parseResultModeToString : ResultMode -> String
parseResultModeToString mode =
    List.filter (\( _, m ) -> m == mode) resultModeOptions
        |> List.head
        |> Maybe.withDefault ( "sources", Sources )
        |> Tuple.first


type alias LabelValue =
    { label : LanguageMap
    , value : LanguageMap
    }


recordTypeFromJsonType : String -> RecordType
recordTypeFromJsonType jsonType =
    case jsonType of
        "rism:Source" ->
            Source

        "rism:Person" ->
            Person

        "rism:Institution" ->
            Institution

        "rism:Incipit" ->
            Incipit

        "rism:Place" ->
            Place

        "rism:LiturgicalFestival" ->
            Festival

        "Collection" ->
            CollectionSearchResult

        _ ->
            Unknown


type alias Relations =
    { label : LanguageMap
    , items : List RelationshipList
    , type_ : String
    }


type alias RelationshipList =
    { label : LanguageMap
    , items : List Relationship
    , type_ : String
    }


type alias Relationship =
    { id : Maybe String
    , type_ : String
    , role : Maybe LanguageMap
    , qualifier : Maybe LanguageMap
    , relatedTo : Maybe RelatedEntity
    , value : Maybe LanguageMap
    }


{-| -}
type alias RelatedEntity =
    { type_ : RecordType
    , label : LanguageMap
    , id : String
    }


type alias ExternalResource =
    { url : String
    , label : LanguageMap
    }


type alias ExternalResourceList =
    { label : LanguageMap
    , items : List ExternalResource
    }


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , sourceType : LanguageMap
    }


type alias Subject =
    { id : String
    , term : LanguageMap
    }


type alias NoteList =
    { label : LanguageMap
    , notes : List LabelValue
    }


type RenderedIncipit
    = RenderedIncipit IncipitFormat String


type alias IncipitRecord =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , rendered : Maybe (List RenderedIncipit)
    }


type alias IncipitList =
    { label : LanguageMap
    , incipits : List IncipitRecord
    }


type alias MaterialGroupList =
    { label : LanguageMap
    , items : List MaterialGroup
    }


type alias MaterialGroup =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , related : Maybe Relations
    }


type alias ExemplarList =
    { id : String
    , label : LanguageMap
    , items : List Exemplar
    }


type alias Exemplar =
    { id : String
    , summary : List LabelValue
    , heldBy : InstitutionBody
    }


type alias SourceBody =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , sourceType : LanguageMap
    , partOf : Maybe (List BasicSourceBody)
    , creator : Maybe Relationship
    , related : Maybe Relations
    , subjects : Maybe (List Subject)
    , notes : Maybe NoteList
    , incipits : Maybe IncipitList
    , materialgroups : Maybe MaterialGroupList
    , exemplars : Maybe ExemplarList
    }


type alias PersonBody =
    { id : String
    , label : LanguageMap
    , sources : Maybe PersonSources
    , summary : List LabelValue
    , seeAlso : Maybe (List SeeAlso)
    , nameVariants : Maybe PersonNameVariantList
    , related : Maybe RelatedList
    , notes : Maybe NoteList
    , externalResources : Maybe ExternalResourceList
    }


type alias PersonSources =
    { id : String
    , totalItems : Int
    }


type alias Relationships =
    { label : LanguageMap
    , items : List Relationship
    }


type alias RelatedList =
    { label : LanguageMap
    , items : List Relationships
    }


type alias PersonNameVariantList =
    { label : LanguageMap
    , items : List LabelValue
    }


type alias SeeAlso =
    { url : String
    , label : LanguageMap
    }


type alias InstitutionBody =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , related : Maybe RelatedList
    }


type alias PlaceBody =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    }


type alias FestivalBody =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    }


type alias SearchBody =
    { id : String
    , items : List SearchResult
    , view : SearchPagination
    , facets : List Facet
    , modes : Facet
    , totalItems : Int
    }


type alias SearchQueryArgs =
    { query : Maybe String
    , filters : List Filter
    , sort : Maybe String
    , page : Int
    , mode : ResultMode
    }


defaultSearchQueryArgs : SearchQueryArgs
defaultSearchQueryArgs =
    SearchQueryArgs Nothing [] Nothing 1 Sources


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


convertFacetToFilter : String -> FacetItem -> Filter
convertFacetToFilter name facet =
    let
        (FacetItem qval label count) =
            facet
    in
    Filter name qval


convertFacetToResultMode : FacetItem -> ResultMode
convertFacetToResultMode facet =
    let
        (FacetItem qval label count) =
            facet
    in
    parseStringToResultMode qval
