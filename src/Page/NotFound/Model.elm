module Page.NotFound.Model exposing (..)

import Response exposing (Response, ServerData)


type alias NotFoundPageModel =
    { response : Response ServerData
    }
