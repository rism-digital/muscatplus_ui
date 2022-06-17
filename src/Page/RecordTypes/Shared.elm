module Page.RecordTypes.Shared exposing
    ( FacetAlias
    , LabelBooleanValue
    , LabelNumericValue
    , LabelStringValue
    , LabelValue
    , RecordHistory
    , labelNumericValueDecoder
    , labelStringValueDecoder
    , labelValueDecoder
    , languageMapLabelDecoder
    , recordHistoryDecoder
    )

import Json.Decode as Decode exposing (Decoder, andThen, bool, float, list, string)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap, languageMapDecoder)
import Page.RecordTypes exposing (RecordType, recordTypeFromJsonType)
import Time


type alias FacetAlias =
    String


type alias LabelBooleanValue =
    { label : LanguageMap
    , value : Bool
    }


type alias LabelNumericValue =
    { label : LanguageMap
    , value : Float
    }


type alias LabelStringValue =
    { label : LanguageMap
    , value : String
    }


type alias LabelValue =
    { label : LanguageMap
    , value : LanguageMap
    }


type alias RecordHistory =
    { createdLabel : LanguageMap
    , created : Time.Posix
    , updatedLabel : LanguageMap
    , updated : Time.Posix
    }


labelNumericValueDecoder : Decoder LabelNumericValue
labelNumericValueDecoder =
    Decode.succeed LabelNumericValue
        |> required "label" languageMapLabelDecoder
        |> required "value" float


labelStringValueDecoder : Decoder LabelStringValue
labelStringValueDecoder =
    Decode.succeed LabelStringValue
        |> required "label" languageMapLabelDecoder
        |> required "value" string


labelValueDecoder : Decoder LabelValue
labelValueDecoder =
    Decode.succeed LabelValue
        |> required "label" languageMapLabelDecoder
        |> required "value" languageMapLabelDecoder


languageMapLabelDecoder : Decoder LanguageMap
languageMapLabelDecoder =
    Decode.keyValuePairs (list string)
        |> andThen languageMapDecoder


recordHistoryDecoder : Decoder RecordHistory
recordHistoryDecoder =
    Decode.succeed RecordHistory
        |> required "createdLabel" languageMapLabelDecoder
        |> required "created" datetime
        |> required "updatedLabel" languageMapLabelDecoder
        |> required "updated" datetime


labelBooleanValueDecoder : Decoder LabelBooleanValue
labelBooleanValueDecoder =
    Decode.succeed LabelBooleanValue
        |> required "label" languageMapLabelDecoder
        |> required "value" bool


toLabel : { a | label : LanguageMap } -> LanguageMap
toLabel labelValue =
    labelValue.label


toNumericValue : { a | value : Float } -> Float
toNumericValue labelValue =
    labelValue.value


toValue : { a | value : LanguageMap } -> LanguageMap
toValue labelValue =
    labelValue.value


typeDecoder : Decoder RecordType
typeDecoder =
    string
        |> andThen (\str -> Decode.succeed (recordTypeFromJsonType str))
