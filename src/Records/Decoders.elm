module Records.Decoders exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, int, list, string)
import Json.Decode.Pipeline exposing (optional, optionalAt, required)
import Records.DataTypes as RDT exposing (BasicSourceBody, Exemplar, ExemplarsList, ExternalResource, ExternalResourceList, Incipit, IncipitFormat(..), IncipitList, InstitutionBody, MaterialGroup, MaterialGroupList, NoteList, PersonBody, PersonNameVariantList, PersonSources, PlaceBody, RecordResponse(..), RelatedEntity, RelatedList, Relationship, Relationships, RenderedIncipit(..), SeeAlso, SourceBody, SourceRelationship, SourceRelationshipList, Subject)
import Shared.DataTypes exposing (RecordType(..), recordTypeFromJsonType)
import Shared.Decoders exposing (labelDecoder, labelValueDecoder, typeDecoder)


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
        |> required "label" labelDecoder
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


incipitDecoder : Decoder RDT.Incipit
incipitDecoder =
    Decode.succeed RDT.Incipit
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
relationshipsDecoder : Decoder Relationships
relationshipsDecoder =
    Decode.succeed Relationships
        |> required "label" labelDecoder
        |> required "items" (list relationshipDecoder)


relatedListDecoder : Decoder RelatedList
relatedListDecoder =
    Decode.succeed RelatedList
        |> required "label" labelDecoder
        |> required "items" (list relationshipsDecoder)


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
        |> optional "related" (Decode.maybe relatedListDecoder) Nothing
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
        |> required "summary" (list labelValueDecoder)
        |> optional "related" (Decode.maybe relatedListDecoder) Nothing


institutionResponseDecoder : Decoder RecordResponse
institutionResponseDecoder =
    Decode.map InstitutionResponse institutionBodyDecoder


placeResponseDecoder : Decoder RecordResponse
placeResponseDecoder =
    Decode.map PlaceResponse placeBodyDecoder


placeBodyDecoder : Decoder PlaceBody
placeBodyDecoder =
    Decode.succeed PlaceBody
        |> required "id" string
        |> required "label" labelDecoder


recordResponseConverter : String -> Decoder RecordResponse
recordResponseConverter typevalue =
    case recordTypeFromJsonType typevalue of
        Source ->
            sourceResponseDecoder

        Person ->
            personResponseDecoder

        Institution ->
            institutionResponseDecoder

        Place ->
            placeResponseDecoder

        -- TODO: This is obviously wrong! Fix it with the actual response types
        --       once we have a clear idea of what they are.
        _ ->
            sourceResponseDecoder


recordResponseDecoder : Decoder RecordResponse
recordResponseDecoder =
    Decode.field "type" string
        |> andThen recordResponseConverter
