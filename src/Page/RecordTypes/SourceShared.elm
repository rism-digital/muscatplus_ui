module Page.RecordTypes.SourceShared exposing
    ( ContentsSectionBody
    , SourceContentType(..)
    , SourceContentTypeRecordBody
    , SourceRecordDescriptors
    , SourceRecordType(..)
    , SourceRecordTypeRecordBody
    , SourceType(..)
    , SourceTypeRecordBody
    , Subject
    , SubjectsSectionBody
    , contentsSectionBodyDecoder
    , sourceContentTypeDecoder
    , sourceContentTypeRecordBodyDecoder
    , sourceRecordDescriptorsDecoder
    , sourceRecordTypeDecoder
    , sourceRecordTypeRecordBodyDecoder
    , sourceTypeDecoder
    , sourceTypeRecordBodyDecoder
    )

import Dict
import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias ContentsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , summary : Maybe (List LabelValue)
    , subjects : Maybe SubjectsSectionBody
    }


type SourceContentType
    = LibrettoContent
    | TreatiseContent
    | MusicalContent
    | MixedContent
    | OtherContent


type alias SourceContentTypeRecordBody =
    { label : LanguageMap
    , type_ : SourceContentType
    }


type alias SourceRecordDescriptors =
    { sourceType : SourceTypeRecordBody
    , contentTypes : List SourceContentTypeRecordBody
    , recordType : SourceRecordTypeRecordBody
    }


type SourceRecordType
    = SourceItemRecord
    | SourceSingleItemRecord
    | SourceCollectionRecord
    | SourceCompositeRecord


type alias SourceRecordTypeRecordBody =
    { label : LanguageMap
    , type_ : SourceRecordType
    }


type SourceType
    = PrintedSource
    | ManuscriptSource
    | CompositeSource
    | UnspecifiedSource


type alias SourceTypeRecordBody =
    { label : LanguageMap
    , type_ : SourceType
    }


type alias Subject =
    { id : String
    , label : LanguageMap
    , value : String
    }


type alias SubjectsSectionBody =
    { label : LanguageMap
    , items : List Subject
    }


contentsSectionBodyDecoder : Decoder ContentsSectionBody
contentsSectionBodyDecoder =
    Decode.succeed ContentsSectionBody
        |> hardcoded "source-record-contents-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "subjects" (Decode.maybe sourceSubjectsBodyDecoder) Nothing


sourceContentTypeDecoder : Decoder SourceContentType
sourceContentTypeDecoder =
    string
        |> andThen
            (\str ->
                sourceContentTypeFromJsonType str
                    |> Decode.succeed
            )


sourceContentTypeFromJsonType : String -> SourceContentType
sourceContentTypeFromJsonType jsonType =
    Dict.fromList sourceContentTypeOptions
        |> Dict.get jsonType
        |> Maybe.withDefault OtherContent


sourceContentTypeOptions : List ( String, SourceContentType )
sourceContentTypeOptions =
    [ ( "rism:LibrettoContent", LibrettoContent )
    , ( "rism:TreatiseContent", TreatiseContent )
    , ( "rism:MusicalContent", MusicalContent )
    , ( "rism:MixedContent", MixedContent )
    , ( "rism:OtherContent", OtherContent )
    ]


sourceContentTypeRecordBodyDecoder : Decoder SourceContentTypeRecordBody
sourceContentTypeRecordBodyDecoder =
    Decode.succeed SourceContentTypeRecordBody
        |> required "label" languageMapLabelDecoder
        |> required "type" sourceContentTypeDecoder


sourceRecordDescriptorsDecoder : Decoder SourceRecordDescriptors
sourceRecordDescriptorsDecoder =
    Decode.succeed SourceRecordDescriptors
        |> required "sourceType" sourceTypeRecordBodyDecoder
        |> required "contentTypes" (list sourceContentTypeRecordBodyDecoder)
        |> required "recordType" sourceRecordTypeRecordBodyDecoder


sourceRecordTypeDecoder : Decoder SourceRecordType
sourceRecordTypeDecoder =
    string
        |> andThen
            (\str ->
                sourceRecordTypeFromJsonType str
                    |> Decode.succeed
            )


sourceRecordTypeFromJsonType : String -> SourceRecordType
sourceRecordTypeFromJsonType jsonType =
    Dict.fromList sourceRecordTypeOptions
        |> Dict.get jsonType
        |> Maybe.withDefault SourceItemRecord


sourceRecordTypeOptions : List ( String, SourceRecordType )
sourceRecordTypeOptions =
    [ ( "rism:ItemRecord", SourceItemRecord )
    , ( "rism:SingleItemRecord", SourceSingleItemRecord )
    , ( "rism:CollectionRecord", SourceCollectionRecord )
    , ( "rism:CompositeRecord", SourceCompositeRecord )
    ]


sourceRecordTypeRecordBodyDecoder : Decoder SourceRecordTypeRecordBody
sourceRecordTypeRecordBodyDecoder =
    Decode.succeed SourceRecordTypeRecordBody
        |> required "label" languageMapLabelDecoder
        |> required "type" sourceRecordTypeDecoder


sourceSubjectDecoder : Decoder Subject
sourceSubjectDecoder =
    Decode.succeed Subject
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "value" string


sourceSubjectsBodyDecoder : Decoder SubjectsSectionBody
sourceSubjectsBodyDecoder =
    Decode.succeed SubjectsSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list sourceSubjectDecoder)


sourceTypeDecoder : Decoder SourceType
sourceTypeDecoder =
    string
        |> andThen
            (\str ->
                sourceTypeFromJsonType str
                    |> Decode.succeed
            )


sourceTypeFromJsonType : String -> SourceType
sourceTypeFromJsonType jsonType =
    Dict.fromList sourceTypeOptions
        |> Dict.get jsonType
        |> Maybe.withDefault UnspecifiedSource


sourceTypeOptions : List ( String, SourceType )
sourceTypeOptions =
    [ ( "rism:PrintedSource", PrintedSource )
    , ( "rism:ManuscriptSource", ManuscriptSource )
    , ( "rism:CompositeSource", CompositeSource )
    , ( "rism:UnspecifiedSource", UnspecifiedSource )
    ]


sourceTypeRecordBodyDecoder : Decoder SourceTypeRecordBody
sourceTypeRecordBodyDecoder =
    Decode.succeed SourceTypeRecordBody
        |> required "label" languageMapLabelDecoder
        |> required "type" sourceTypeDecoder
