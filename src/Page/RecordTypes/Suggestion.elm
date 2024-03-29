module Page.RecordTypes.Suggestion exposing (ActiveSuggestion(..), suggestionResponseDecoder, toAlias, toSuggestionList)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Page.RecordTypes.Shared exposing (FacetAlias, LabelValue, labelValueDecoder)


{-|

    ActiveSuggestion <alias> <list of suggestions>

-}
type ActiveSuggestion
    = ActiveSuggestion FacetAlias (List LabelValue)


suggestionResponseDecoder : Decoder ActiveSuggestion
suggestionResponseDecoder =
    Decode.succeed ActiveSuggestion
        |> required "alias" string
        |> required "items" (Decode.list labelValueDecoder)


toAlias : ActiveSuggestion -> FacetAlias
toAlias (ActiveSuggestion alias _) =
    alias


toSuggestionList : ActiveSuggestion -> List LabelValue
toSuggestionList (ActiveSuggestion _ suggestions) =
    suggestions
