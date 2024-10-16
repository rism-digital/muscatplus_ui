module Page.UI.Pagination exposing (viewPagination)

import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, height, htmlAttribute, padding, pointer, px, row, shrink, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Search exposing (SearchPagination)
import Page.UI.Attributes exposing (headingLG, minimalDropShadow)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (chevronDoubleLeftSvg, chevronDoubleRightSvg, chevronLeftSvg, chevronRightSvg)
import Page.UI.Style exposing (colourScheme)


paginationLink : Element a -> (String -> a) -> String -> Element a
paginationLink icon clickFn url =
    el
        [ padding 5
        , height (px 40)
        , width (px 40)
        , onClick (clickFn url)
        , pointer
        ]
        icon


viewPagination : Language -> SearchPagination -> (String -> msg) -> Element msg
viewPagination language pagination clickMsg =
    let
        pageLabel =
            extractLabelFromLanguageMap language localTranslations.page

        thisPage =
            formatNumberByLanguage language (toFloat pagination.thisPage)

        totalPages =
            formatNumberByLanguage language (toFloat pagination.totalPages)

        pageInfo =
            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages
    in
    row
        [ width fill
        , alignBottom
        , height (px 50)
        , Background.color colourScheme.lightGrey
        , Border.color colourScheme.midGrey
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , minimalDropShadow
        , htmlAttribute (HA.style "z-index" "10")
        ]
        [ column
            [ alignLeft
            , width fill
            ]
            [ row
                [ width shrink
                , alignLeft
                ]
                [ viewMaybe (paginationLink (chevronDoubleLeftSvg colourScheme.darkBlue) clickMsg) (Just pagination.first)
                , viewMaybe (paginationLink (chevronLeftSvg colourScheme.darkBlue) clickMsg) pagination.previous
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
                    [ headingLG
                    , Font.medium
                    ]
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
                [ viewMaybe (paginationLink (chevronRightSvg colourScheme.darkBlue) clickMsg) pagination.next
                , viewMaybe (paginationLink (chevronDoubleRightSvg colourScheme.darkBlue) clickMsg) pagination.last
                ]
            ]
        ]
