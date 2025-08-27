module Page.RecordTypes.PartOf exposing (..)

import Json.Decode as Decode exposing (Decoder, field, list, map, maybe, oneOf)
import Json.Decode.Pipeline exposing (custom, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Publication exposing (BasicPublicationBody, basicPublicationBodyDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)
import Page.RecordTypes.WorkBasic exposing (BasicWorkBody, basicWorkBodyDecoder)


type alias PartOfSectionBody =
    { label : LanguageMap
    , partOf : PartOf
    , other : Maybe (List PartOf)
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
        |> custom partOfDecoder
        |> optional "other" (maybe (list otherPartOfDecoder)) Nothing


partOfDecoder : Decoder PartOf
partOfDecoder =
    oneOf
        [ partOfSourceDecoder
        , partOfPublicationDecoder
        , partOfWorkDecoder
        ]


otherPartOfDecoder : Decoder PartOf
otherPartOfDecoder =
    oneOf
        [ basicSourceBodyDecoder |> map SourcePart
        , basicPublicationBodyDecoder |> map PublicationPart
        , basicWorkBodyDecoder |> map WorkPart
        ]


partOfSourceDecoder : Decoder PartOf
partOfSourceDecoder =
    field "source" basicSourceBodyDecoder
        |> map SourcePart


partOfPublicationDecoder : Decoder PartOf
partOfPublicationDecoder =
    field "publication" basicPublicationBodyDecoder
        |> map PublicationPart


partOfWorkDecoder : Decoder PartOf
partOfWorkDecoder =
    field "work" basicWorkBodyDecoder
        |> map WorkPart
