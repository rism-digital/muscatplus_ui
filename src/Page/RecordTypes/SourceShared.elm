module Page.RecordTypes.SourceShared exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody, relationshipBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias SourceRecordDescriptors =
    { sourceType : SourceTypeRecordBody
    , contentTypes : List SourceContentTypeRecordBody
    , recordType : SourceRecordTypeRecordBody
    }


type alias SourceTypeRecordBody =
    { label : LanguageMap
    , type_ : SourceType
    }


type alias SourceContentTypeRecordBody =
    { label : LanguageMap
    , type_ : SourceContentType
    }


type alias SourceRecordTypeRecordBody =
    { label : LanguageMap
    , type_ : SourceRecordType
    }


contentsSectionBodyDecoder : Decoder ContentsSectionBody
contentsSectionBodyDecoder =
    Decode.succeed ContentsSectionBody
        |> hardcoded "source-record-contents-section"
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (Decode.maybe relationshipBodyDecoder) Nothing
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "subjects" (Decode.maybe sourceSubjectsBodyDecoder) Nothing


sourceSubjectsBodyDecoder : Decoder SubjectsSectionBody
sourceSubjectsBodyDecoder =
    Decode.succeed SubjectsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list sourceSubjectDecoder)


sourceSubjectDecoder : Decoder Subject
sourceSubjectDecoder =
    Decode.succeed Subject
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "value" string


sourceRecordDescriptorsDecoder : Decoder SourceRecordDescriptors
sourceRecordDescriptorsDecoder =
    Decode.succeed SourceRecordDescriptors
        |> required "sourceType" sourceTypeRecordBodyDecoder
        |> required "contentTypes" (list sourceContentTypeRecordBodyDecoder)
        |> required "recordType" sourceRecordTypeRecordBodyDecoder


type SourceType
    = PrintedSource
    | ManuscriptSource
    | CompositeSource
    | UnspecifiedSource


sourceTypeOptions : List ( String, SourceType )
sourceTypeOptions =
    [ ( "rism:PrintedSource", PrintedSource )
    , ( "rism:ManuscriptSource", ManuscriptSource )
    , ( "rism:CompositeSource", CompositeSource )
    , ( "rism:UnspecifiedSource", UnspecifiedSource )
    ]


sourceTypeFromJsonType : String -> SourceType
sourceTypeFromJsonType jsonType =
    List.filter (\( str, _ ) -> str == jsonType) sourceTypeOptions
        |> List.head
        |> Maybe.withDefault ( "", UnspecifiedSource )
        |> Tuple.second


sourceTypeRecordBodyDecoder : Decoder SourceTypeRecordBody
sourceTypeRecordBodyDecoder =
    Decode.succeed SourceTypeRecordBody
        |> required "label" languageMapLabelDecoder
        |> required "type" sourceTypeDecoder


sourceTypeDecoder : Decoder SourceType
sourceTypeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (sourceTypeFromJsonType str))


type SourceRecordType
    = SourceItemRecord
    | SourceCollectionRecord
    | SourceCompositeRecord


sourceRecordTypeOptions : List ( String, SourceRecordType )
sourceRecordTypeOptions =
    [ ( "rism:ItemRecord", SourceItemRecord )
    , ( "rism:CollectionRecord", SourceCollectionRecord )
    , ( "rism:CompositeRecord", SourceCompositeRecord )
    ]


sourceRecordTypeFromJsonType : String -> SourceRecordType
sourceRecordTypeFromJsonType jsonType =
    List.filter (\( str, _ ) -> str == jsonType) sourceRecordTypeOptions
        |> List.head
        |> Maybe.withDefault ( "", SourceItemRecord )
        |> Tuple.second


sourceRecordTypeRecordBodyDecoder : Decoder SourceRecordTypeRecordBody
sourceRecordTypeRecordBodyDecoder =
    Decode.succeed SourceRecordTypeRecordBody
        |> required "label" languageMapLabelDecoder
        |> required "type" sourceRecordTypeDecoder


sourceRecordTypeDecoder : Decoder SourceRecordType
sourceRecordTypeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (sourceRecordTypeFromJsonType str))


type SourceContentType
    = LibrettoContent
    | TreatiseContent
    | MusicalContent
    | CompositeContent


sourceContentTypeOptions : List ( String, SourceContentType )
sourceContentTypeOptions =
    [ ( "rism:LibrettoContent", LibrettoContent )
    , ( "rism:TreatiseContent", TreatiseContent )
    , ( "rism:MusicalContent", MusicalContent )
    , ( "rism:CompositeContent", CompositeContent )
    ]


sourceContentTypeFromJsonType : String -> SourceContentType
sourceContentTypeFromJsonType jsonType =
    List.filter (\( str, _ ) -> str == jsonType) sourceContentTypeOptions
        |> List.head
        |> Maybe.withDefault ( "", MusicalContent )
        |> Tuple.second


sourceContentTypeRecordBodyDecoder : Decoder SourceContentTypeRecordBody
sourceContentTypeRecordBodyDecoder =
    Decode.succeed SourceContentTypeRecordBody
        |> required "label" languageMapLabelDecoder
        |> required "type" sourceContentTypeDecoder


sourceContentTypeDecoder : Decoder SourceContentType
sourceContentTypeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (sourceContentTypeFromJsonType str))


type alias Subject =
    { id : String
    , label : LanguageMap
    , value : String
    }


type alias SubjectsSectionBody =
    { label : LanguageMap
    , items : List Subject
    }


type alias ContentsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , summary : Maybe (List LabelValue)
    , subjects : Maybe SubjectsSectionBody
    }
