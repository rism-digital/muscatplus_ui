module Page.NotFound.Msg exposing (..)

import Http
import Http.Detailed
import Response exposing (ServerData)


type NotFoundMsg
    = ServerRespondedWithNotFoundData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | NothingHappened
