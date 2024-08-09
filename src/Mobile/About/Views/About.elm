module Mobile.About.Views.About exposing (view)

import Element exposing (Element, none)
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg)
import Session exposing (Session)


view : Session -> AboutPageModel -> Element AboutMsg
view session model =
    none
