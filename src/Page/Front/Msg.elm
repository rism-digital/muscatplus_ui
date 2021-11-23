module Page.Front.Msg exposing (..)

import Http
import Http.Detailed
import Response exposing (ServerData)


type FrontMsg
    = ServerRespondedWithFrontData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | NothingHappened
