module Page.RecordTypes.Shared exposing
    ( FacetAlias
    , LabelBooleanValue
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
import Language exposing (LanguageMap, languageMapDecoder)
import Page.RecordTypes exposing (RecordType, recordTypeFromJsonType)
import Time


type alias FacetAlias =
    String


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
    { sourceType : SourceTypeRecordBody
    , contentTypes : List SourceContentTypeRecordBody
    , recordType : SourceRecordTypeRecordBody
    }


type alias SourceTypeRecordBody =
    { label : LanguageMap, type_ : SourceType }


type alias SourceContentTypeRecordBody =
    { label : LanguageMap, type_ : SourceContentType }


type alias SourceRecordTypeRecordBody =
    { label : LanguageMap, type_ : SourceRecordType }


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
