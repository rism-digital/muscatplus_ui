module Page.About.Msg exposing (AboutMsg(..))

import Http
import Http.Detailed
import Response exposing (ServerData)


type AboutMsg
    = ServerRespondedWithAboutData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | UserToggledEnableMuscatLinks
