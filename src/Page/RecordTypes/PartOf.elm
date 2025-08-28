module Page.RecordTypes.PartOf exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, field, list, map, maybe, oneOf, string)
import Json.Decode.Pipeline exposing (custom, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes exposing (RecordType(..), recordTypeFromJsonType)
import Page.RecordTypes.Publication exposing (BasicPublicationBody, basicPublicationBodyDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)
import Page.RecordTypes.WorkBasic exposing (BasicWorkBody, basicWorkBodyDecoder)


type alias RelatedBlock =
    { primary : PartOf
    , secondary : Maybe (List PartOf)
    }


type alias PartOfSectionBody =
    { label : LanguageMap
    , related : RelatedBlock
    }


type PartOf
    = SourcePart BasicSourceBody
    | PublicationPart BasicPublicationBody
    | WorkPart BasicWorkBody


extractUrlAndLabelFromPartOf : PartOf -> ( String, LanguageMap )
extractUrlAndLabelFromPartOf partOf =
    case partOf of
        SourcePart s ->
            ( s.id, s.label )

        WorkPart w ->
            ( w.id, w.label )

        PublicationPart p ->
            ( p.id, p.label )


partOfSectionBodyDecoder : Decoder PartOfSectionBody
partOfSectionBodyDecoder =
    Decode.succeed PartOfSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "related" relatedBlockDecoder


relatedBlockDecoder : Decoder RelatedBlock
relatedBlockDecoder =
    Decode.succeed RelatedBlock
        |> required "primary" partOfDecoder
        |> optional "secondary" (maybe (list partOfDecoder)) Nothing


recordTypePartOfDecoder : RecordType -> Decoder PartOf
recordTypePartOfDecoder rt =
    case rt of
        Source ->
            basicSourceBodyDecoder |> map SourcePart

        Work ->
            basicWorkBodyDecoder |> map WorkPart

        Publication ->
            basicPublicationBodyDecoder |> map PublicationPart

        _ ->
            Decode.fail "Record type is not valid in a part of context."


partOfDecoder : Decoder PartOf
partOfDecoder =
    field "type" string
        |> map recordTypeFromJsonType
        |> andThen recordTypePartOfDecoder
