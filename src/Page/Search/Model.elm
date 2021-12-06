module Page.Search.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Response exposing (Response)


type alias SearchPageModel =
    { response : Response
    , activeSearch : ActiveSearch
    , preview : Response
    , selectedResult : Maybe String
    , showFacetPanel : Bool
    }
