module Page.UI.Facets.Shared exposing (facetTitleBar)

import Element exposing (Element, alignLeft, alignTop, centerY, el, fill, height, onRight, padding, row, shrink, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (h6e)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (facetTooltip)


facetTitleBar :
    { extraControls : List (Element msg)
    , language : Language
    , title : LanguageMap
    , tooltip : LanguageMap
    }
    -> Element msg
facetTitleBar cfg =
    row
        [ width fill
        , alignTop
        , spacing lineSpacing
        , padding 8
        , Background.color colourScheme.lightGrey
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , Border.color colourScheme.midGrey
        ]
        (el
            [ width shrink
            , height shrink
            , centerY
            ]
            (facetTooltip onRight (extractLabelFromLanguageMap cfg.language cfg.tooltip))
            :: el
                [ alignLeft
                , centerY
                , width fill
                ]
                (h6e cfg.language cfg.title)
            :: cfg.extraControls
        )
