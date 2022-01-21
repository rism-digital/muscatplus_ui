module Page.Record.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Response exposing (Response, ServerData)


type CurrentRecordViewTab
    = DefaultRecordViewTab
    | PersonSourcesRecordSearchTab String
    | InstitutionSourcesRecordSearchTab String


type alias RecordPageModel =
    { response : Response ServerData
    , currentTab : CurrentRecordViewTab
    , searchResults : Response ServerData
    , activeSearch : ActiveSearch
    }
