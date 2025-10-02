module Page.UI.Search.Pagination exposing (viewPagination, viewTablePagination)

import Element exposing (Color, Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, height, htmlAttribute, padding, pointer, px, row, shrink, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Search exposing (SearchPagination)
import Page.UI.Attributes exposing (emptyAttribute, headingMD, minimalDropShadow)
import Page.UI.Images exposing (chevronDoubleLeftSvg, chevronDoubleRightSvg, chevronLeftSvg, chevronRightSvg)
import Page.UI.Style exposing (colourScheme)


paginationLink : (Color -> Element a) -> (String -> a) -> Maybe String -> Element a
paginationLink icon clickFn url =
    let
        thisIcon =
            case url of
                Just _ ->
                    icon colourScheme.darkBlue

                Nothing ->
                    icon colourScheme.midGrey

        thisPointer =
            case url of
                Just _ ->
                    pointer

                Nothing ->
                    htmlAttribute (HA.style "cursor" "not-allowed")

        clickAttr =
            case url of
                Just u ->
                    onClick (clickFn u)

                Nothing ->
                    emptyAttribute
    in
    el
        [ padding 5
        , height (px 30)
        , width (px 30)
        , clickAttr
        , thisPointer
        ]
        thisIcon


viewTablePagination : Language -> SearchPagination -> (String -> msg) -> Element msg
viewTablePagination language pagination clickMsg =
    let
        rowStyle =
            row
                [ htmlAttribute (HA.style "width" "50%")
                , centerX
                ]
    in
    viewPaginationImpl
        { clickMsg = clickMsg
        , language = language
        , pagination = pagination
        , rowStyle = rowStyle
        }


viewPaginationImpl :
    { clickMsg : String -> msg
    , language : Language
    , pagination : SearchPagination
    , rowStyle : List (Element msg) -> Element msg
    }
    -> Element msg
viewPaginationImpl { clickMsg, language, pagination, rowStyle } =
    let
        pageLabel =
            extractLabelFromLanguageMap language localTranslations.page

        thisPage =
            formatNumberByLanguage language (toFloat pagination.thisPage)

        totalPages =
            formatNumberByLanguage language (toFloat pagination.totalPages)

        pageInfo =
            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages

        firstLink =
            if pagination.thisPage /= 1 && pagination.totalPages > 1 then
                Just pagination.first

            else
                Nothing
    in
    rowStyle
        [ column
            [ alignLeft
            , width fill
            ]
            [ row
                [ width shrink
                , alignLeft
                ]
                [ paginationLink chevronDoubleLeftSvg clickMsg firstLink
                , paginationLink chevronLeftSvg clickMsg pagination.previous
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
                    [ headingMD
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
                [ paginationLink chevronRightSvg clickMsg pagination.next
                , paginationLink chevronDoubleRightSvg clickMsg pagination.last
                ]
            ]
        ]


viewPagination : Language -> SearchPagination -> (String -> msg) -> Element msg
viewPagination language pagination clickMsg =
    let
        rowStyle =
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
    in
    viewPaginationImpl { clickMsg = clickMsg, language = language, pagination = pagination, rowStyle = rowStyle }
