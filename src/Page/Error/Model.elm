module Page.Error.Model exposing (ErrorPageModel)

import Response exposing (Response, ServerData)


type alias ErrorPageModel =
    { response : Response ServerData
    }
