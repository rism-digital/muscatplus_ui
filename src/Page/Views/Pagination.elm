module Page.Views.Pagination exposing (..)

import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, height, padding, pointer, px, row, shrink, text, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Msg exposing (Msg(..))
import Page.RecordTypes.Search exposing (SearchPagination)
import Page.UI.Images exposing (chevronDoubleLeftSvg, chevronDoubleRightSvg, chevronLeftSvg, chevronRightSvg)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Helpers exposing (viewMaybe)


viewPagination : Language -> SearchPagination -> (String -> msg) -> Element msg
viewPagination language pagination clickMsg =
    let
        firstLabel =
            extractLabelFromLanguageMap language localTranslations.first

        previousLabel =
            extractLabelFromLanguageMap language localTranslations.previous

        nextLabel =
            extractLabelFromLanguageMap language localTranslations.next

        lastLabel =
            extractLabelFromLanguageMap language localTranslations.last

        thisPage =
            formatNumberByLanguage (toFloat pagination.thisPage) language

        totalPages =
            formatNumberByLanguage (toFloat pagination.totalPages) language

        pageLabel =
            extractLabelFromLanguageMap language localTranslations.page

        pageInfo =
            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages
    in
    row
        [ width fill
        , alignBottom
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
    let
        clickMsg =
            clickFn url
    in
    el
        [ padding 5
        , height (px 40)
        , width (px 40)
        , onClick clickMsg
        , pointer
        ]
        icon
