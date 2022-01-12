module ActiveSearch.Model exposing (..)

import Dict exposing (Dict)
import Page.Query exposing (QueryArgs)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.UI.Keyboard as Keyboard


{-|

    The 'nextQuery' parameter is what is modified by the search options, and
    will form the "next query" that is sent to the server when the user submits
    their search.

    The other options help keep track of the state of search options, UI config,
    etc.

-}
type alias ActiveSearch =
    { nextQuery : QueryArgs
    , expandedFacets : List String
    , rangeFacetValues : Dict FacetAlias ( String, String )

    --, activeFacets : Dict FacetAlias (List String)
    , keyboard : Keyboard.Model
    , selectedResultSort : Maybe String
    , activeSuggestion : Maybe ActiveSuggestion
    }
