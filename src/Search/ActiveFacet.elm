module Search.ActiveFacet exposing (..)

import Language exposing (LanguageMap)
import Page.RecordTypes.Search exposing (FacetType)


type alias FacetLabel =
    LanguageMap


type alias FacetValue =
    LanguageMap


type ActiveFacet
    = ActiveFacet FacetType FacetLabel FacetValue
