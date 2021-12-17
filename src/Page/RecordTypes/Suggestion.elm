module Page.RecordTypes.Suggestion exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder)


{-|

    ActiveSuggestion <alias> <list of suggestions>

-}
type ActiveSuggestion
    = ActiveSuggestion String (List LabelValue)


suggestionResponseDecoder : Decoder ActiveSuggestion
suggestionResponseDecoder =
    Decode.succeed ActiveSuggestion
        |> required "alias" string
        |> required "items" (Decode.list labelValueDecoder)
