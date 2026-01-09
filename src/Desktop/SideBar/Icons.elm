module Desktop.SideBar.Icons exposing (sidebarIcon, sidebarRowBaseOptions, sidebarRowColumnBaseOptions)

import Element exposing (Attribute, Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, padding, paddingXY, px, shrink, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Page.UI.Style exposing (colourScheme)


sidebarIcon : List (Attribute msg) -> Element msg -> Element msg
sidebarIcon extraAttrs icon =
    column
        (width (px 35)
            :: padding 2
            :: alignLeft
            :: extraAttrs
        )
        [ el
            [ width (px 20)
            , centerY
            , centerX
            ]
            icon
        ]


sidebarRowBaseOptions : List (Attribute msg)
sidebarRowBaseOptions =
    [ width fill
    , alignLeft
    , paddingXY 0 8
    , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
    , Border.color colourScheme.darkBlue
    , Background.color colourScheme.darkBlue
    ]


sidebarRowColumnBaseOptions : List (Attribute msg)
sidebarRowColumnBaseOptions =
    [ width fill
    , height fill
    , centerX
    , alignTop
    , spacing 10
    ]
