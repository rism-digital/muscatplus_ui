module Page.Views.Pagination exposing (..)

import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, height, padding, px, row, shrink, text, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Msg exposing (Msg(..))
import Page.RecordTypes.Search exposing (SearchPagination)
import Page.UI.Images exposing (chevronDoubleLeftSvg, chevronDoubleRightSvg, chevronLeftSvg, chevronRightSvg)
import Page.UI.Style exposing (colourScheme, colours)
import Page.Views.Helpers exposing (viewMaybe)


viewRecordSourceResultsPagination : Language -> SearchPagination -> Element Msg
viewRecordSourceResultsPagination language pagination =
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
                [ viewMaybe (paginationLink (chevronDoubleLeftSvg colours.slateGrey) firstLabel) (Just pagination.first)
                , viewMaybe (paginationLink (chevronLeftSvg colours.slateGrey) previousLabel) pagination.previous
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
                [ viewMaybe (paginationLink (chevronRightSvg colours.slateGrey) nextLabel) pagination.next
                , viewMaybe (paginationLink (chevronDoubleRightSvg colours.slateGrey) lastLabel) pagination.last
                ]
            ]
        ]


paginationLink : Element Msg -> String -> String -> Element Msg
paginationLink icon iconLabel url =
    el
        [ padding 5
        , height (px 20)
        , width (px 20)
        , onClick (UserClickedRecordViewTabPagination url)
        ]
        icon
