module Page.RecordTypes.Shared exposing (LabelNumericValue, LabelValue, labelDecoder, labelNumericValueDecoder, labelValueDecoder, typeDecoder)

import Json.Decode as Decode exposing (Decoder, andThen, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap, LanguageNumericMap, languageMapDecoder, languageNumericMapDecoder)
import Page.RecordTypes exposing (RecordType, recordTypeFromJsonType)


type alias LabelValue =
    { label : LanguageMap
    , value : LanguageMap
    }


type alias LabelNumericValue =
    { label : LanguageMap
    , value : LanguageNumericMap
    }


labelValueDecoder : Decoder LabelValue
labelValueDecoder =
    Decode.succeed LabelValue
        |> required "label" labelDecoder
        |> required "value" labelDecoder


labelNumericValueDecoder : Decoder LabelNumericValue
labelNumericValueDecoder =
    Decode.succeed LabelNumericValue
        |> required "label" labelDecoder
        |> required "value" numericValueDecoder


labelDecoder : Decoder LanguageMap
labelDecoder =
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