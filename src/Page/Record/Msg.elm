module Page.Record.Msg exposing (..)

import Http
import Http.Detailed
import Page.Record.Model exposing (CurrentRecordViewTab)
import Response exposing (ServerData)


type RecordMsg
    = ServerRespondedWithPageSearch (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithRecordData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | UserClickedRecordViewTab CurrentRecordViewTab
    | UserClickedToCItem String
    | NothingHappened
