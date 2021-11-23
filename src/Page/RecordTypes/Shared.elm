module Page.RecordTypes.Shared exposing
    ( LabelBooleanValue
    , LabelNumericValue
    , LabelValue
    , RecordHistory
    , SourceRecordDescriptors
    , labelBooleanValueDecoder
    , labelNumericValueDecoder
    , labelValueDecoder
    , languageMapLabelDecoder
    , recordHistoryDecoder
    , sourceRecordDescriptorsDecoder
    , typeDecoder
    )

import Json.Decode as Decode exposing (Decoder, andThen, bool, float, list, string)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap, LanguageNumericMap, languageMapDecoder)
import Page.RecordTypes exposing (RecordType, recordTypeFromJsonType)
import Time


type alias LabelValue =
    { label : LanguageMap
    , value : LanguageMap
    }


type alias LabelNumericValue =
    { label : LanguageMap
    , value : Float
    }


type alias LabelBooleanValue =
    { label : LanguageMap
    , value : Bool
    }


type alias RecordHistory =
    { createdLabel : LanguageMap
    , created : Time.Posix
    , updatedLabel : LanguageMap
    , updated : Time.Posix
    }


labelValueDecoder : Decoder LabelValue
labelValueDecoder =
    Decode.succeed LabelValue
        |> required "label" languageMapLabelDecoder
        |> required "value" languageMapLabelDecoder


labelNumericValueDecoder : Decoder LabelNumericValue
labelNumericValueDecoder =
    Decode.succeed LabelNumericValue
        |> required "label" languageMapLabelDecoder
        |> required "value" float


labelBooleanValueDecoder : Decoder LabelBooleanValue
labelBooleanValueDecoder =
    Decode.succeed LabelBooleanValue
        |> required "label" languageMapLabelDecoder
        |> required "value" bool


languageMapLabelDecoder : Decoder LanguageMap
languageMapLabelDecoder =
    Decode.keyValuePairs (list string)
        |> andThen languageMapDecoder


typeDecoder : Decoder RecordType
typeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (recordTypeFromJsonType str))


recordHistoryDecoder : Decoder RecordHistory
recordHistoryDecoder =
    Decode.succeed RecordHistory
        |> required "createdLabel" languageMapLabelDecoder
        |> required "created" datetime
        |> required "updatedLabel" languageMapLabelDecoder
        |> required "updated" datetime


type alias SourceRecordDescriptors =
    { sourceType : SourceType
    , contentType : SourceContentType
    , recordType : SourceRecordType
    }


sourceRecordDescriptorsDecoder : Decoder SourceRecordDescriptors
sourceRecordDescriptorsDecoder =
    Decode.succeed SourceRecordDescriptors
        |> required "sourceType" sourceTypeDecoder
        |> required "contentType" sourceContentTypeDecoder
        |> required "recordType" sourceRecordTypeDecoder


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


sourceTypeDecoder : Decoder SourceType
sourceTypeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (sourceTypeFromJsonType str))


type SourceRecordType
    = SourceContentsRecord
    | SourceCollectionRecord
    | SourceCompositeRecord


sourceRecordTypeOptions : List ( String, SourceRecordType )
sourceRecordTypeOptions =
    [ ( "rism:ContentsRecord", SourceContentsRecord )
    , ( "rism:CollectionRecord", SourceCollectionRecord )
    , ( "rism:CompositeRecord", SourceCompositeRecord )
    ]


sourceRecordTypeFromJsonType : String -> SourceRecordType
sourceRecordTypeFromJsonType jsonType =
    List.filter (\( str, _ ) -> str == jsonType) sourceRecordTypeOptions
        |> List.head
        |> Maybe.withDefault ( "", SourceContentsRecord )
        |> Tuple.second


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


sourceContentTypeDecoder : Decoder SourceContentType
sourceContentTypeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (sourceContentTypeFromJsonType str))
