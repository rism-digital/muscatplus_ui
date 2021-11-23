module Page.Record.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Response exposing (Response)


type CurrentRecordViewTab
    = DefaultRecordViewTab
    | PersonSourcesRecordSearchTab String
    | InstitutionSourcesRecordSearchTab String


type alias RecordPageModel =
    { response : Response
    , currentTab : CurrentRecordViewTab
    , searchResults : Response
    , activeSearch : ActiveSearch
    }
