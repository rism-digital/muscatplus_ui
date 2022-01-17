module Page.Front.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Response exposing (Response)


type alias FrontPageModel =
    { response : Response
    , activeSearch : ActiveSearch
    }
