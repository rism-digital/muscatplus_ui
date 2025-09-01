module Page.RecordTypes.PartOf exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, field, list, map, maybe, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes exposing (RecordType(..), recordTypeFromJsonType)
import Page.RecordTypes.Publication exposing (BasicPublicationBody, basicPublicationBodyDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)
import Page.RecordTypes.WorkBasic exposing (BasicWorkBody, basicWorkBodyDecoder)


type alias RelatedBlock =
    { relatedTo : PartOf
    , relationshipType : PartOfType
    , workInfo : Maybe String
    }


type alias PartOfSectionBody =
    { label : LanguageMap
    , items : List RelatedBlock
    }


type PartOfType
    = PrimaryPartOf
    | SecondaryPartOf


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
        |> required "items" (list relatedBlockDecoder)


relatedBlockDecoder : Decoder RelatedBlock
relatedBlockDecoder =
    Decode.succeed RelatedBlock
        |> required "relatedTo" partOfDecoder
        |> required "relationshipType" (string |> andThen partOfTypeDecoder)
        |> optional "workNumber" (maybe string) Nothing


partOfTypeDecoder : String -> Decoder PartOfType
partOfTypeDecoder partOfType =
    case partOfType of
        "rism:PrimaryPartOf" ->
            succeed PrimaryPartOf

        "rism:SecondaryPartOf" ->
            succeed SecondaryPartOf

        _ ->
            Decode.fail "could not determine part of type"


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
