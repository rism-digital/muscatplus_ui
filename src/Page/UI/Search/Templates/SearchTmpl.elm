module Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl, viewSearchResultsNotFoundTmpl)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, none, padding, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (h3, renderParagraph)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme)


viewResultsListLoadingScreenTmpl : Bool -> Element msg
viewResultsListLoadingScreenTmpl isLoading =
    if isLoading then
        el
            [ width fill
            , height fill
            , Background.color colourScheme.translucentGrey
            , htmlAttribute (HA.attribute "style" "backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px); z-index:200;")
            ]
            (el
                [ width (px 50)
                , height (px 50)
                , centerX
                , centerY
                ]
                (animatedLoader [ width (px 50), height (px 50) ] (spinnerSvg colourScheme.midGrey))
            )

    else
        none


viewSearchResultsErrorTmpl : Language -> String -> Element msg
viewSearchResultsErrorTmpl language err =
    text err


viewSearchResultsLoadingTmpl : Language -> Element msg
viewSearchResultsLoadingTmpl language =
    row
        [ width fill
        ]
        [ column
            [ width fill
            , height fill
            , Background.color colourScheme.white
            , scrollbarY
            , alignTop
            ]
            []
        ]


viewSearchResultsNotFoundTmpl : Language -> Element msg
viewSearchResultsNotFoundTmpl language =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , padding 20
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ h3 language localTranslations.noResultsHeader ]
            , row
                [ width fill ]
                [ renderParagraph language localTranslations.noResultsBody ]
            ]
        ]
