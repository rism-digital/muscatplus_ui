module Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig, SearchControlsConfig)

import ActiveSearch.Model exposing (ActiveSearch)
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (Facets)
import Page.UI.Facets.FacetsConfig exposing (FacetConfig, FacetMsgConfig)
import Response exposing (Response)
import Session exposing (Session)
import Set exposing (Set)


type alias ControlsConfig body msg =
    { language : Language
    , activeSearch : ActiveSearch msg
    , body : { body | facets : Facets }
    , numberOfSelectColumns : Int
    , expandedFacetPanels : Set String
    , panelToggleMsg : String -> Set String -> msg
    , facetMsgConfig : FacetMsgConfig msg
    }


type alias SearchControlsConfig a b msg =
    { session : Session
    , model :
        { a
            | activeSearch : ActiveSearch msg
            , probeResponse : Response ProbeData
            , applyFilterPrompt : Bool
        }
    , body : { b | facets : Facets }
    , checkboxColumns : Int
    , facetMsgConfig : FacetMsgConfig msg
    , panelToggleMsg : String -> Set String -> msg
    , userTriggeredSearchSubmitMsg : msg
    , userEnteredTextInKeywordQueryBoxMsg : String -> msg
    }


type alias PanelConfig =
    { alias : String
    , label : LanguageMap
    }
