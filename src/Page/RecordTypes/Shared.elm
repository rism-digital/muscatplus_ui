module Page.RecordTypes.Shared exposing
    ( FacetAlias
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

import Json.Decode as Decode exposing (Decoder, andThen, float, list, string)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap, languageMapDecoder)
import Time


type alias FacetAlias =
    String


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


type alias LabelTimeValue =
    { label : LanguageMap
    , value : Time.Posix
    }


type alias RecordHistory =
    { created : LabelTimeValue
    , updated : LabelTimeValue
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


labelTimeValueDecoder : Decoder LabelTimeValue
labelTimeValueDecoder =
    Decode.succeed LabelTimeValue
        |> required "label" languageMapLabelDecoder
        |> required "value" datetime


languageMapLabelDecoder : Decoder LanguageMap
languageMapLabelDecoder =
    Decode.keyValuePairs (list string)
        |> andThen languageMapDecoder


recordHistoryDecoder : Decoder RecordHistory
recordHistoryDecoder =
    Decode.succeed RecordHistory
        |> required "created" labelTimeValueDecoder
        |> required "updated" labelTimeValueDecoder
