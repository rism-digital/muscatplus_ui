module Page.Converters exposing (..)

import Page.RecordTypes exposing (Filter(..))
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..))


convertFacetToFilter : String -> FacetItem -> Filter
convertFacetToFilter name facet =
    let
        (FacetItem qval label count) =
            facet
    in
    Filter name qval


convertFacetToResultMode : FacetItem -> ResultMode
convertFacetToResultMode facet =
    let
        (FacetItem qval label count) =
            facet
    in
    parseStringToResultMode qval
