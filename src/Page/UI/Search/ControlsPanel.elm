module Page.UI.Search.ControlsPanel exposing (viewSearchControlsPanel)

import Element exposing (Element, alignLeft, alignTop, column, fill, height, width)
import Page.UI.Search.SearchComponents exposing (SearchButtonConfig, viewSearchButtons)


viewSearchControlsPanel :
    { activeFilters : Element msg
    , body : Element msg
    , buttonsConfig : SearchButtonConfig model msg
    }
    -> Element msg
viewSearchControlsPanel cfg =
    column
        [ width fill
        , height fill
        , alignTop
        , alignLeft
        ]
        [ viewSearchButtons cfg.buttonsConfig
        , cfg.activeFilters
        , cfg.body
        ]
