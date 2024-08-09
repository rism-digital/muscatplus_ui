module Mobile.Search.Views exposing (view)

import Element exposing (Element, none)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg)
import Session exposing (Session)


view : Session -> SearchPageModel SearchMsg -> Element SearchMsg
view session model =
    none
