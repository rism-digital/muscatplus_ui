module Page.Record.Msg exposing (..)

import Http
import Http.Detailed
import Page.Record.Model exposing (CurrentRecordViewTab)
import Response exposing (ServerData)


type RecordMsg
    = ServerRespondedWithPageSearch (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithRecordData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithRecordPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | UserClickedRecordViewTab CurrentRecordViewTab
    | UserClickedToCItem String
    | UserClickedSearchResultsPagination String
    | UserClickedSearchResultForPreview String
    | UserClickedClosePreviewWindow
    | NothingHappened
