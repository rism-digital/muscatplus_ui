module Api.Records exposing (..)

import Api.DataTypes exposing (RecordType(..), recordTypeFromJsonType)
import Api.Request exposing (createRequest)
import Api.Search exposing (labelDecoder)
import Config as C
import Http
import Json.Decode as Decode exposing (Decoder, andThen, int, list, nullable, string)
import Json.Decode.Pipeline exposing (optional, required, requiredAt)
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


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , sourceType : LanguageMap
    }


type alias SourceRelationship =
    { id : String
    , role : LanguageMap
    , person : PersonBody
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
    , textIncipit : Maybe LanguageMap
    , rendered : Maybe (List RenderedIncipit)
    }


type alias IncipitList =
    { label : LanguageMap
    , incipits : List Incipit
    }


type alias SourceBody =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , sourceType : LanguageMap
    , partOf : Maybe (List BasicSourceBody)
    , creator : Maybe SourceRelationship
    , subjects : Maybe (List Subject)
    , notes : Maybe NoteList
    , incipits : Maybe IncipitList
    }


type alias PersonBody =
    { id : String
    , label : LanguageMap
    , sources : Maybe PersonSources
    , nameVariants : Maybe PersonNameVariants
    , externalReferences : Maybe (List PersonExternalReferences)
    }


type alias PersonSources =
    { id : String
    , totalItems : Int
    }


type alias PersonNameVariants =
    { label : LanguageMap
    , values : LanguageMap
    }


type alias PersonExternalReferences =
    { id : String
    , type_ : String
    }


type alias InstitutionBody =
    { id : String
    , label : LanguageMap
    }


type RecordResponse
    = SourceResponse SourceBody
    | PersonResponse PersonBody
    | InstitutionResponse InstitutionBody


sourceResponseDecoder : Decoder RecordResponse
sourceResponseDecoder =
    Decode.map SourceResponse sourceBodyDecoder


sourceBodyDecoder : Decoder SourceBody
sourceBodyDecoder =
    Decode.succeed SourceBody
        |> required "id" string
        |> required "label" labelDecoder
        |> required "summary" (list noteDecoder)
        |> required "sourceType" labelDecoder
        |> optional "partOf" (Decode.maybe (list basicSourceBodyDecoder)) Nothing
        |> optional "creator" (Decode.maybe sourceRelationshipDecoder) Nothing
        |> optional "subjects" (Decode.maybe (list subjectDecoder)) Nothing
        |> optional "notes" (Decode.maybe noteListDecoder) Nothing
        |> optional "incipits" (Decode.maybe incipitListDecoder) Nothing


basicSourceBodyDecoder : Decoder BasicSourceBody
basicSourceBodyDecoder =
    Decode.succeed BasicSourceBody
        |> required "id" string
        |> required "label" labelDecoder
        |> required "sourceType" labelDecoder


sourceRelationshipDecoder : Decoder SourceRelationship
sourceRelationshipDecoder =
    Decode.succeed SourceRelationship
        |> required "id" string
        |> requiredAt [ "role", "label" ] labelDecoder
        |> required "relatedTo" personBodyDecoder


subjectDecoder : Decoder Subject
subjectDecoder =
    Decode.succeed Subject
        |> required "id" string
        |> required "term" string


noteListDecoder : Decoder NoteList
noteListDecoder =
    Decode.succeed NoteList
        |> required "label" labelDecoder
        |> required "items" (list noteDecoder)


noteDecoder : Decoder LabelValue
noteDecoder =
    Decode.succeed LabelValue
        |> required "label" labelDecoder
        |> required "value" labelDecoder


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
        |> required "summary" (list noteDecoder)
        |> optional "textIncipit" (Decode.maybe labelDecoder) Nothing
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


personSourcesDecoder : Decoder PersonSources
personSourcesDecoder =
    Decode.succeed PersonSources
        |> required "id" string
        |> required "totalItems" int


personNameVariantsDecoder : Decoder PersonNameVariants
personNameVariantsDecoder =
    Decode.succeed PersonNameVariants
        |> required "label" labelDecoder
        |> required "values" labelDecoder


personExternalReferencesDecoder : Decoder PersonExternalReferences
personExternalReferencesDecoder =
    Decode.succeed PersonExternalReferences
        |> required "id" string
        |> required "type" string


personResponseDecoder : Decoder RecordResponse
personResponseDecoder =
    Decode.map PersonResponse personBodyDecoder


personBodyDecoder : Decoder PersonBody
personBodyDecoder =
    Decode.succeed PersonBody
        |> required "id" string
        |> required "label" labelDecoder
        |> optional "sources" (Decode.maybe personSourcesDecoder) Nothing
        |> optional "nameVariants" (Decode.maybe personNameVariantsDecoder) Nothing
        |> optional "seeAlso" (Decode.maybe (list personExternalReferencesDecoder)) Nothing


institutionBodyDecoder : Decoder InstitutionBody
institutionBodyDecoder =
    Decode.succeed InstitutionBody
        |> required "id" string
        |> required "label" labelDecoder


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


recordResponseDecoder : Decoder RecordResponse
recordResponseDecoder =
    Decode.field "type" string
        |> andThen recordResponseConverter


recordUrl : List String -> String
recordUrl pathSegments =
    let
        qstring =
            ""
    in
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
