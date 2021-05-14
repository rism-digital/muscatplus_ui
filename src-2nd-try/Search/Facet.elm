module Search.Facet exposing (convertFacetToFilter, convertFacetToResultMode)

import Api.RecordTypes exposing (FacetItem(..), Filter(..))
import Api.Response exposing (ResultMode, parseStringToResultMode)


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
