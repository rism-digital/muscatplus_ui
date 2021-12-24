module Page.RecordTypes.Countries exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelStringValue, labelStringValueDecoder)


type alias CountryCode =
    String


countryLabelValueToDict : List LabelStringValue -> Dict CountryCode LanguageMap
countryLabelValueToDict labelValueList =
    List.map (\{ label, value } -> ( value, label )) labelValueList
        |> Dict.fromList


countryCodeDecoder : Decoder (Dict CountryCode LanguageMap)
countryCodeDecoder =
    Decode.field "items" (Decode.list labelStringValueDecoder)
        |> Decode.map countryLabelValueToDict
