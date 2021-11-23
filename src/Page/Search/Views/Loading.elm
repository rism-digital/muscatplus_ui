module Page.Search.Views.Loading exposing (..)

import Element exposing (Element, alignLeft, alignTop, centerY, column, fill, height, maximum, minimum, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language)
import Msg exposing (Msg)
import Page.Search.Model exposing (SearchPageModel)
import Page.UI.Animations exposing (loadingBox)
import Page.UI.Attributes exposing (searchColumnVerticalSize)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewSearchResultsLoading : Language -> SearchPageModel -> Element msg
viewSearchResultsLoading language model =
    row
        [ width fill
        ]
        [ column
            [ width (fill |> minimum 600 |> maximum 1100)
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            []
        , column
            [ Border.widthEach { top = 0, left = 2, right = 0, bottom = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            , width (fill |> minimum 800)
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            []
        ]


viewSearchResultLoadingAnimation : Element msg
viewSearchResultLoadingAnimation =
    row
        [ width fill
        , alignTop
        , paddingXY 20 20
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 10
            ]
            [ row
                [ width fill
                , alignLeft
                ]
                [ loadingBox 400 20 ]
            , row
                [ width fill
                , alignLeft
                ]
                [ loadingBox 600 50
                ]
            ]
        ]


searchModeSelectorLoading : Element msg
searchModeSelectorLoading =
    row
        [ width fill ]
        [ column
            [ width fill
            , spacing 20
            ]
            [ row
                [ width fill
                , height (px 40)
                , paddingXY 20 0
                , spacing 40
                , centerY
                ]
                []
            ]
        ]
