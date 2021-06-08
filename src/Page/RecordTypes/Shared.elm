module Page.RecordTypes.Shared exposing (LabelNumericValue, LabelValue, RecordHistory, labelNumericValueDecoder, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder, typeDecoder)

import Json.Decode as Decode exposing (Decoder, andThen, int, list, string)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap, LanguageNumericMap, languageMapDecoder, languageNumericMapDecoder)
import Page.RecordTypes exposing (Filter, RecordType, recordTypeFromJsonType)
import Time


type alias LabelValue =
    { label : LanguageMap
    , value : LanguageMap
    }


type alias LabelNumericValue =
    { label : LanguageMap
    , value : LanguageNumericMap
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
        |> required "value" numericValueDecoder


languageMapLabelDecoder : Decoder LanguageMap
languageMapLabelDecoder =
    Decode.keyValuePairs (list string)
        |> andThen languageMapDecoder


numericValueDecoder : Decoder LanguageNumericMap
numericValueDecoder =
    Decode.keyValuePairs (list int)
        |> andThen languageNumericMapDecoder


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
