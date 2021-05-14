module Page.FrontPage exposing (..)

import Element exposing (Element, alignTop, centerX, centerY, column, fill, height, paddingXY, row, text, width)
import Model exposing (Model)
import Msg exposing (Msg)
import Search.SearchInput exposing (searchKeywordInput)
import UI.Attributes exposing (desktopResponsiveWidth)


view : Model -> Element Msg
view model =
    row
        [ width fill
        , height fill
        , centerX
        ]
        [ searchKeywordInput model ]
