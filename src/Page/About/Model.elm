module Page.About.Model exposing (AboutPageModel)

import Response exposing (Response, ServerData)


type alias AboutPageModel =
    { response : Response ServerData
    }
