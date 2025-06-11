module Page.Error.Msg exposing (NotFoundMsg(..))

import Http
import Http.Detailed
import Page.RecordTypes.ApiError exposing (ApiError)


type NotFoundMsg
    = ServerRespondedWithNotFoundData (Result (Http.Detailed.Error String) ( Http.Metadata, ApiError ))
