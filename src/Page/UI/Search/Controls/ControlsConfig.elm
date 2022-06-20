module Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)

import ActiveSearch.Model exposing (ActiveSearch)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.UI.Facets.Facets exposing (FacetMsgConfig)


type alias ControlsConfig msg =
    { language : Language
    , activeSearch : ActiveSearch msg
    , body : SearchBody
    , numberOfSelectColumns : Int
    , sectionToggleMsg : msg
    , userTriggeredSearchSubmitMsg : msg
    , userEnteredTextInKeywordQueryBoxMsg : String -> msg
    , facetMsgConfig : FacetMsgConfig msg
    }