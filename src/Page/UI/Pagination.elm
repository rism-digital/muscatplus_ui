module Page.UI.Pagination exposing (..)

import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, height, padding, pointer, px, row, shrink, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Search exposing (SearchPagination)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (chevronDoubleLeftSvg, chevronDoubleRightSvg, chevronLeftSvg, chevronRightSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewPagination : Language -> SearchPagination -> (String -> msg) -> Element msg
viewPagination language pagination clickMsg =
    let
        thisPage =
            formatNumberByLanguage language (toFloat pagination.thisPage)

        totalPages =
            formatNumberByLanguage language (toFloat pagination.totalPages)

        pageLabel =
            extractLabelFromLanguageMap language localTranslations.page

        pageInfo =
            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages
    in
    row
        [ width fill
        , alignBottom
        , height (px 50)
        , Background.color (colourScheme.lightGrey |> convertColorToElementColor)
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
        , minimalDropShadow
        ]
        [ column
            [ alignLeft
            , width fill
            ]
            [ row
                [ width shrink
                , alignLeft
                ]
                [ viewMaybe (paginationLink (chevronDoubleLeftSvg colourScheme.slateGrey) clickMsg) (Just pagination.first)
                , viewMaybe (paginationLink (chevronLeftSvg colourScheme.slateGrey) clickMsg) pagination.previous
                ]
            ]
        , column
            [ centerX
            , width fill
            ]
            [ row
                [ width shrink
                , height shrink
                , centerX
                , centerY
                ]
                [ el
                    [ Font.medium ]
                    (text pageInfo)
                ]
            ]
        , column
            [ alignRight
            , width fill
            ]
            [ row
                [ width shrink
                , alignRight
                ]
                [ viewMaybe (paginationLink (chevronRightSvg colourScheme.slateGrey) clickMsg) pagination.next
                , viewMaybe (paginationLink (chevronDoubleRightSvg colourScheme.slateGrey) clickMsg) pagination.last
                ]
            ]
        ]


paginationLink : Element a -> (String -> a) -> String -> Element a
paginationLink icon clickFn url =
    el
        [ padding 5
        , height (px 40)
        , width (px 40)
        , onClick <| clickFn url
        , pointer
        ]
        icon
