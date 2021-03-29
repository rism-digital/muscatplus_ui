module Api.Records exposing (..)

import Api.DataTypes exposing (RecordType(..), recordTypeFromJsonType, typeDecoder)
import Api.Request exposing (createRequest)
import Api.Search exposing (labelDecoder)
import Config as C
import Http
import Json.Decode as Decode exposing (Decoder, andThen, int, list, string)
import Json.Decode.Pipeline exposing (optional, optionalAt, required)
import Language exposing (LanguageMap, LanguageValues)
import Url.Builder


type ApiResponse
    = Loading
    | Response RecordResponse
    | ApiError


type IncipitFormat
    = RenderedSVG
    | RenderedMIDI
    | UnknownFormat


type alias Relationship =
    { id : Maybe String
    , role : Maybe LanguageMap
    , qualifier : Maybe LanguageMap
    , relatedTo : Maybe RelatedEntity
    , value : Maybe LanguageMap
    }


{-| -}
type alias RelatedEntity =
    { type_ : RecordType
    , name : LanguageMap
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


type alias SourceRelationship =
    { id : Maybe String
    , role : Maybe LanguageMap
    , qualifier : Maybe LanguageMap
    , person : PersonBody
    }


type alias SourceRelationshipList =
    { id : Maybe String
    , label : LanguageMap
    , items : List SourceRelationship
    }


type alias Subject =
    { id : String
    , term : String
    }


type alias LabelValue =
    { label : LanguageMap
    , value : LanguageMap
    }


type alias NoteList =
    { label : LanguageMap
    , notes : List LabelValue
    }


type RenderedIncipit
    = RenderedIncipit IncipitFormat String


type alias Incipit =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , rendered : Maybe (List RenderedIncipit)
    }


type alias IncipitList =
    { label : LanguageMap
    , incipits : List Incipit
    }


type alias MaterialGroupList =
    { label : LanguageMap
    , items : List MaterialGroup
    }


type alias MaterialGroup =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , related : Maybe SourceRelationshipList
    }


type alias ExemplarsList =
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
    , creator : Maybe SourceRelationship
    , related : Maybe SourceRelationshipList
    , subjects : Maybe (List Subject)
    , notes : Maybe NoteList
    , incipits : Maybe IncipitList
    , materialgroups : Maybe MaterialGroupList
    , exemplars : Maybe ExemplarsList
    }


type alias PersonBody =
    { id : String
    , label : LanguageMap
    , sources : Maybe PersonSources
    , summary : List LabelValue
    , seeAlso : Maybe (List SeeAlso)
    , nameVariants : Maybe PersonNameVariantList
    , relations : Maybe PersonRelationList
    , notes : Maybe NoteList
    , externalResources : Maybe ExternalResourceList
    }


type alias PersonSources =
    { id : String
    , totalItems : Int
    }


type alias PersonRelation =
    { label : LanguageMap
    , items : List Relationship
    }


type alias PersonRelationList =
    { label : LanguageMap
    , items : List PersonRelation
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
    , siglum : LanguageMap
    }


type RecordResponse
    = SourceResponse SourceBody
    | PersonResponse PersonBody
    | InstitutionResponse InstitutionBody


labelValueDecoder : Decoder LabelValue
labelValueDecoder =
    Decode.succeed LabelValue
        |> required "label" labelDecoder
        |> required "value" labelDecoder


{-|

    Decoder for the structures used to communicate relationships.
    Most of the keys are optional since not all relationships will have all keys,
    but most relationships will have some combination of them.

-}
relationshipDecoder : Decoder Relationship
relationshipDecoder =
    Decode.succeed Relationship
        |> optional "id" (Decode.maybe string) Nothing
        |> optionalAt [ "role", "label" ] (Decode.maybe labelDecoder) Nothing
        |> optionalAt [ "qualifier", "label" ] (Decode.maybe labelDecoder) Nothing
        |> optional "relatedTo" (Decode.maybe relatedEntityDecoder) Nothing
        |> optional "value" (Decode.maybe labelDecoder) Nothing


relatedEntityDecoder : Decoder RelatedEntity
relatedEntityDecoder =
    Decode.succeed RelatedEntity
        |> required "type" typeDecoder
        |> required "name" labelDecoder
        |> required "id" string


externalResourceListDecoder : Decoder ExternalResourceList
externalResourceListDecoder =
    Decode.succeed ExternalResourceList
        |> required "label" labelDecoder
        |> required "items" (list externalResourceDecoder)


externalResourceDecoder : Decoder ExternalResource
externalResourceDecoder =
    Decode.succeed ExternalResource
        |> required "url" string
        |> required "label" labelDecoder


sourceResponseDecoder : Decoder RecordResponse
sourceResponseDecoder =
    Decode.map SourceResponse sourceBodyDecoder


sourceBodyDecoder : Decoder SourceBody
sourceBodyDecoder =
    Decode.succeed SourceBody
        |> required "id" string
        |> required "label" labelDecoder
        |> required "summary" (list labelValueDecoder)
        |> required "sourceType" labelDecoder
        |> optional "partOf" (Decode.maybe (list basicSourceBodyDecoder)) Nothing
        |> optional "creator" (Decode.maybe sourceRelationshipDecoder) Nothing
        |> optional "related" (Decode.maybe sourceRelationshipListDecoder) Nothing
        |> optional "subjects" (Decode.maybe (list subjectDecoder)) Nothing
        |> optional "notes" (Decode.maybe noteListDecoder) Nothing
        |> optional "incipits" (Decode.maybe incipitListDecoder) Nothing
        |> optional "materials" (Decode.maybe materialGroupListDecoder) Nothing
        |> optional "exemplars" (Decode.maybe exemplarListDecoder) Nothing


basicSourceBodyDecoder : Decoder BasicSourceBody
basicSourceBodyDecoder =
    Decode.succeed BasicSourceBody
        |> required "id" string
        |> required "label" labelDecoder
        |> required "sourceType" labelDecoder


sourceRelationshipDecoder : Decoder SourceRelationship
sourceRelationshipDecoder =
    Decode.succeed SourceRelationship
        |> optional "id" (Decode.maybe string) Nothing
        |> optionalAt [ "role", "label" ] (Decode.maybe labelDecoder) Nothing
        |> optionalAt [ "qualifier", "label" ] (Decode.maybe labelDecoder) Nothing
        |> required "relatedTo" personBodyDecoder


sourceRelationshipListDecoder : Decoder SourceRelationshipList
sourceRelationshipListDecoder =
    Decode.succeed SourceRelationshipList
        |> optional "id" (Decode.maybe string) Nothing
        |> required "label" labelDecoder
        |> required "items" (list sourceRelationshipDecoder)


subjectDecoder : Decoder Subject
subjectDecoder =
    Decode.succeed Subject
        |> required "id" string
        |> required "term" string


noteListDecoder : Decoder NoteList
noteListDecoder =
    Decode.succeed NoteList
        |> required "label" labelDecoder
        |> required "items" (list labelValueDecoder)


materialGroupListDecoder : Decoder MaterialGroupList
materialGroupListDecoder =
    Decode.succeed MaterialGroupList
        |> required "label" labelDecoder
        |> required "items" (list materialGroupDecoder)


materialGroupDecoder : Decoder MaterialGroup
materialGroupDecoder =
    Decode.succeed MaterialGroup
        |> required "id" string
        |> required "label" labelDecoder
        |> required "summary" (list labelValueDecoder)
        |> optional "related" (Decode.maybe sourceRelationshipListDecoder) Nothing


incipitListDecoder : Decoder IncipitList
incipitListDecoder =
    Decode.succeed IncipitList
        |> required "label" labelDecoder
        |> required "items" (list incipitDecoder)


incipitDecoder : Decoder Incipit
incipitDecoder =
    Decode.succeed Incipit
        |> required "id" string
        |> required "label" labelDecoder
        |> required "summary" (list labelValueDecoder)
        |> optional "rendered" (Decode.maybe (list renderedIncipitDecoder)) Nothing


incipitFormatDecoder : Decoder IncipitFormat
incipitFormatDecoder =
    Decode.string
        |> Decode.andThen
            (\mimetype ->
                case mimetype of
                    "audio/midi" ->
                        Decode.succeed RenderedMIDI

                    "image/svg+xml" ->
                        Decode.succeed RenderedSVG

                    _ ->
                        Decode.succeed UnknownFormat
            )


renderedIncipitDecoder : Decoder RenderedIncipit
renderedIncipitDecoder =
    Decode.succeed RenderedIncipit
        |> required "format" incipitFormatDecoder
        |> required "data" string


exemplarListDecoder : Decoder ExemplarsList
exemplarListDecoder =
    Decode.succeed ExemplarsList
        |> required "id" string
        |> required "label" labelDecoder
        |> required "items" (list exemplarDecoder)


exemplarDecoder : Decoder Exemplar
exemplarDecoder =
    Decode.succeed Exemplar
        |> required "id" string
        |> required "summary" (list labelValueDecoder)
        |> required "heldBy" institutionBodyDecoder


personSourcesDecoder : Decoder PersonSources
personSourcesDecoder =
    Decode.succeed PersonSources
        |> required "id" string
        |> required "totalItems" int


{-|

    Used for Person to Person, Person to Place, and Person to Institution relationships

-}
personRelationDecoder : Decoder PersonRelation
personRelationDecoder =
    Decode.succeed PersonRelation
        |> required "label" labelDecoder
        |> required "items" (list relationshipDecoder)


personRelationListDecoder : Decoder PersonRelationList
personRelationListDecoder =
    Decode.succeed PersonRelationList
        |> required "label" labelDecoder
        |> required "items" (list personRelationDecoder)


personNameVariantListDecoder : Decoder PersonNameVariantList
personNameVariantListDecoder =
    Decode.succeed PersonNameVariantList
        |> required "label" labelDecoder
        |> required "items" (list labelValueDecoder)


personResponseDecoder : Decoder RecordResponse
personResponseDecoder =
    Decode.map PersonResponse personBodyDecoder


personBodyDecoder : Decoder PersonBody
personBodyDecoder =
    Decode.succeed PersonBody
        |> required "id" string
        |> required "label" labelDecoder
        |> optional "sources" (Decode.maybe personSourcesDecoder) Nothing
        |> required "summary" (list labelValueDecoder)
        |> optional "seeAlso" (Decode.maybe (list seeAlsoDecoder)) Nothing
        |> optional "nameVariants" (Decode.maybe personNameVariantListDecoder) Nothing
        |> optional "relations" (Decode.maybe personRelationListDecoder) Nothing
        |> optional "notes" (Decode.maybe noteListDecoder) Nothing
        |> optional "externalResources" (Decode.maybe externalResourceListDecoder) Nothing


seeAlsoDecoder : Decoder SeeAlso
seeAlsoDecoder =
    Decode.succeed SeeAlso
        |> required "url" string
        |> required "label" labelDecoder


institutionBodyDecoder : Decoder InstitutionBody
institutionBodyDecoder =
    Decode.succeed InstitutionBody
        |> required "id" string
        |> required "label" labelDecoder
        |> required "siglum" labelDecoder


institutionResponseDecoder : Decoder RecordResponse
institutionResponseDecoder =
    Decode.map InstitutionResponse institutionBodyDecoder


recordResponseConverter : String -> Decoder RecordResponse
recordResponseConverter typevalue =
    case recordTypeFromJsonType typevalue of
        Source ->
            sourceResponseDecoder

        Person ->
            personResponseDecoder

        Institution ->
            institutionResponseDecoder

        -- TODO: This is obviously wrong! Fix it.
        _ ->
            sourceResponseDecoder


recordResponseDecoder : Decoder RecordResponse
recordResponseDecoder =
    Decode.field "type" string
        |> andThen recordResponseConverter


recordUrl : List String -> String
recordUrl pathSegments =
    Url.Builder.crossOrigin C.serverUrl pathSegments []


recordRequest : (Result Http.Error RecordResponse -> msg) -> String -> Cmd msg
recordRequest responseMsg path =
    let
        pathSegments =
            path
                |> String.dropLeft 1
                |> String.split "/"

        url =
            recordUrl pathSegments
    in
    createRequest responseMsg recordResponseDecoder url
