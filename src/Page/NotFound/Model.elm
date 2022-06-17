module Page.NotFound.Model exposing (NotFoundPageModel)

import Response exposing (Response, ServerData)


type alias NotFoundPageModel =
    { response : Response ServerData
    }
