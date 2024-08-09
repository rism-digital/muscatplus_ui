module Mobile.Front.Views exposing (view)

import Element exposing (Element, fill, height, row, text, width)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg)
import Session exposing (Session)


view : Session -> FrontPageModel FrontMsg -> Element FrontMsg
view session model =
    row
        [ width fill
        , height fill
        ]
        [ text "Hello Mobile World" ]
