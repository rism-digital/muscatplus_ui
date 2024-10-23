module Page.Search.Model exposing (SearchPageModel)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer)
import Page.RecordTypes.Probe exposing (ProbeData, ProbeStatus)
import Page.UI.Animations exposing (PreviewAnimationStatus)
import Response exposing (Response, ServerData)
import Set exposing (Set)


{-|

    Only one suggestion is (maybe) available at a time.

-}
type alias SearchPageModel msg =
    { response : Response ServerData
    , activeSearch : ActiveSearch msg
    , preview : Response ServerData
    , sourceItemsExpanded : Bool
    , incipitInfoExpanded : Set String
    , selectedResult : Maybe String
    , showFacetPanel : Bool
    , probeResponse : ProbeStatus
    , probeDebouncer : Debouncer msg
    , applyFilterPrompt : Bool
    , digitizedCopiesCalloutExpanded : Bool
    , previewAnimationStatus : PreviewAnimationStatus
    }
