module ActiveSearch.Model exposing (..)

import Debouncer.Messages exposing (Debouncer)
import Dict exposing (Dict)
import Page.Keyboard as Keyboard
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Query exposing (QueryArgs)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)


{-|

    The 'nextQuery' parameter is what is modified by the search options, and
    will form the "next query" that is sent to the server when the user submits
    their search.

    The other options help keep track of the state of search options, UI config,
    etc.

-}
type alias ActiveSearch msg =
    { nextQuery : QueryArgs
    , expandedFacets : List String
    , rangeFacetValues : Dict FacetAlias ( String, String )
    , queryFacetValues : Dict FacetAlias String
    , keyboard : Keyboard.Model KeyboardMsg
    , selectedResultSort : Maybe String
    , activeSuggestion : Maybe ActiveSuggestion
    , activeSuggestionDebouncer : Debouncer msg
    }
