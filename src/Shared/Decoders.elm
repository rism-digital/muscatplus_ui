module Shared.Decoders exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap, languageMapDecoder)
import Shared.DataTypes exposing (LabelValue, RecordType, recordTypeFromJsonType)


typeDecoder : Decoder RecordType
typeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (recordTypeFromJsonType str))


labelDecoder : Decoder LanguageMap
labelDecoder =
    Decode.keyValuePairs (list string)
        |> andThen languageMapDecoder


labelValueDecoder : Decoder LabelValue
labelValueDecoder =
    Decode.succeed LabelValue
        |> required "label" labelDecoder
        |> required "value" labelDecoder
