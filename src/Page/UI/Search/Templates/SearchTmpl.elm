module Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl, viewSearchResultsNotFoundTmpl)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, none, padding, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (h3, renderParagraph)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewResultsListLoadingScreenTmpl : Bool -> Element msg
viewResultsListLoadingScreenTmpl isLoading =
    if isLoading then
        el
            [ width fill
            , height fill
            , Background.color (colourScheme.translucentGrey |> convertColorToElementColor)
            ]
            (el
                [ width (px 50)
                , height (px 50)
                , centerX
                , centerY
                ]
                (animatedLoader [ width (px 50), height (px 50) ] (spinnerSvg colourScheme.slateGrey))
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
            , Background.color (colourScheme.white |> convertColorToElementColor)
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
