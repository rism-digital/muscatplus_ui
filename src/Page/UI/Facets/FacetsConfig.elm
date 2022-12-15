module Page.UI.Facets.FacetsConfig exposing (FacetConfig, FacetMsgConfig, createFacetConfig)

import ActiveSearch.Model exposing (ActiveSearch)
import Language exposing (Language, LanguageMap)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, Facets, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import SearchPreferences exposing (SearchPreferences)


type alias FacetConfig a msg =
    { alias : FacetAlias
    , language : Language
    , activeSearch : ActiveSearch msg
    , selectColumns : Int
    , body : { a | facets : Facets }
    , tooltip : LanguageMap
    , searchPreferences : Maybe SearchPreferences
    }


type alias FacetMsgConfig msg =
    { userClickedToggleMsg : FacetAlias -> msg
    , userLostFocusRangeMsg : FacetAlias -> msg
    , userFocusedRangeMsg : FacetAlias -> msg
    , userEnteredTextRangeMsg : FacetAlias -> RangeFacetValue -> String -> msg
    , userClickedFacetExpandSelectMsg : String -> msg
    , userChangedFacetBehaviourSelectMsg : FacetAlias -> FacetBehaviours -> msg
    , userChangedSelectFacetSortSelectMsg : FacetAlias -> FacetSorts -> msg
    , userSelectedFacetItemSelectMsg : FacetAlias -> String -> msg
    , userInteractedWithPianoKeyboard : KeyboardMsg -> msg
    , userRemovedQueryMsg : String -> String -> msg
    , userEnteredTextQueryMsg : FacetAlias -> String -> String -> msg
    , userChangedBehaviourQueryMsg : FacetAlias -> FacetBehaviours -> msg
    , userChoseOptionQueryMsg : FacetAlias -> String -> FacetBehaviours -> msg
    , nothingHappenedMsg : msg
    }


createFacetConfig :
    { c
        | activeSearch : ActiveSearch msg
        , body : { a | facets : Facets }
        , language : Language
        , numberOfSelectColumns : Int
    }
    -> String
    -> LanguageMap
    -> FacetConfig a msg
createFacetConfig cfg alias tooltip =
    { alias = alias
    , language = cfg.language
    , activeSearch = cfg.activeSearch
    , selectColumns = cfg.numberOfSelectColumns
    , body = cfg.body
    , tooltip = tooltip
    , searchPreferences = Nothing
    }
