module Page.RecordTypes.Relationship exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type RelatedTo
    = PersonRelationship
    | InstitutionRelationship
    | PlaceRelationship
    | UnknownRelationship


type alias RelationshipBody =
    { summary : Maybe (List LabelValue)
    , role : Maybe String
    , qualifier : Maybe String
    , relatedTo : Maybe RelatedToBody
    }


type alias RelatedToBody =
    { id : String
    , label : LanguageMap
    , type_ : RelatedTo
    }


relatedToTypeDecoder : Decoder RelatedTo
relatedToTypeDecoder =
    Decode.string
        |> andThen relatedToConverter


relatedToBodyDecoder : Decoder RelatedToBody
relatedToBodyDecoder =
    Decode.succeed RelatedToBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "type" relatedToTypeDecoder



--|> required "type" relatedToTypeDecoder


relatedToConverter : String -> Decoder RelatedTo
relatedToConverter typeString =
    case typeString of
        "rism:Person" ->
            Decode.succeed PersonRelationship

        "rism:Institution" ->
            Decode.succeed InstitutionRelationship

        "rism:Place" ->
            Decode.succeed PlaceRelationship

        _ ->
            Decode.succeed UnknownRelationship


relationshipBodyDecoder : Decoder RelationshipBody
relationshipBodyDecoder =
    Decode.succeed RelationshipBody
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "role" (Decode.maybe string) Nothing
        |> optional "qualifier" (Decode.maybe string) Nothing
        |> optional "relatedTo" (Decode.maybe relatedToBodyDecoder) Nothing
