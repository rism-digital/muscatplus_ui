module Page.About.Model exposing (..)

import Response exposing (Response, ServerData)


type alias AboutPageModel =
    { response : Response ServerData
    }
