module Mobile.About.About exposing (view)

import Element exposing (Element, none)
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg)
import Session exposing (Session)


view : Session -> AboutPageModel -> Element AboutMsg
view _ _ =
    none
