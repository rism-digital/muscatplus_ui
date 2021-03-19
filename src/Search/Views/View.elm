module Search.Views.View exposing (viewSearchBody)

import Api.Search exposing (ApiResponse(..), SearchPagination, SearchQueryArgs, SearchResult)
import Element exposing (..)
import Element.Input as Input
import Html
import Html.Attributes
import Language exposing (Language, extractLabelFromLanguageMap, languageOptionsForDisplay, localTranslations)
import Search.DataTypes exposing (Model, Msg(..), Route(..))
import Search.Views.Facets exposing (viewSidebarFacets, viewTypeFacet)
import Search.Views.Results exposing (viewResultList)
import Search.Views.Shared exposing (onEnter)
import UI.Layout exposing (layoutBody)
import UI.Style as Style exposing (greyBackground, minMaxFillDesktop, minMaxFillMobile, roundedBorder, roundedButton)


viewSearchDesktop : Model -> Element Msg
viewSearchDesktop model =
    case model.currentRoute of
        FrontPageRoute ->
            viewSearchFrontDesktop model

        SearchPageRoute _ ->
            viewSearchResultsDesktop model

        NotFound ->
            viewNotFound


viewNotFound : Element Msg
viewNotFound =
    row [] [ text "Route not found" ]


viewSearchFrontDesktop : Model -> Element Msg
viewSearchFrontDesktop model =
    row
        [ width fill
        , height fill
        , centerX
        , centerY
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            , centerY
            ]
            [ row
                [ width fill
                , height (px 60)
                , centerX
                , centerY
                ]
                [ column
                    [ width minMaxFillDesktop
                    , height fill
                    , centerX
                    , centerY
                    ]
                    [ row
                        [ width fill
                        , height fill
                        , centerX
                        , centerY
                        ]
                        [ text "Search RISM Online" ]
                    ]
                ]
            , row
                [ width fill
                , height (px 120)
                , greyBackground
                , centerX
                , centerY
                ]
                [ column
                    [ width minMaxFillDesktop
                    , height fill
                    , centerX
                    ]
                    [ viewSearchKeywordInput model ]
                ]
            ]
        ]


viewSearchKeywordInput : Model -> Element Msg
viewSearchKeywordInput model =
    let
        queryObj =
            model.query

        qText =
            Maybe.withDefault "" queryObj.query

        currentLanguage =
            model.language
    in
    row
        [ centerX
        , height shrink
        , width
            (fill
                |> maximum Style.desktopMaxWidth
                |> minimum Style.desktopMinWidth
            )
        ]
        [ column
            [ width (fillPortion 10)
            , height shrink
            ]
            [ Input.text
                [ width fill
                , height shrink
                , spacingXY 0 4
                , roundedBorder
                , htmlAttribute (Html.Attributes.autocomplete False)
                , onEnter SearchSubmit
                ]
                { onChange = \inp -> SearchInput inp
                , placeholder = Just (Input.placeholder [] (text "Enter your query"))
                , text = qText
                , label = Input.labelHidden (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        , column
            [ width (fillPortion 2) ]
            [ Input.button (List.concat [ roundedButton, [] ])
                { onPress = Just SearchSubmit
                , label = text (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        ]


viewSearchBarSection : Model -> Element Msg
viewSearchBarSection model =
    row
        [ width fill
        , height (px 120)
        , greyBackground
        ]
        [ column
            [ width minMaxFillDesktop
            , height fill
            , centerX
            ]
            [ viewSearchKeywordInput model ]
        ]


viewSearchResultsSection : Model -> Element Msg
viewSearchResultsSection model =
    let
        resp =
            model.response

        itemCount =
            case resp of
                Response searchResponse ->
                    List.length searchResponse.items

                _ ->
                    0

        viewResults =
            if itemCount > 0 then
                viewHasSearchResults model

            else
                viewHasNoSearchResults model
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width minMaxFillDesktop
            , height fill
            , centerX
            , alignTop
            ]
            viewResults
        ]


viewHasNoSearchResults : Model -> List (Element Msg)
viewHasNoSearchResults model =
    [ row
        [ width fill ]
        [ text "No results were returned" ]
    ]


viewHasSearchResults : Model -> List (Element Msg)
viewHasSearchResults model =
    [ viewTypeFacet model
    , row
        [ width fill
        , alignTop
        , spacingXY 20 20
        , paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
        ]
        [ column
            [ width (fillPortion 3)
            , alignTop
            ]
            [ viewSidebarFacets model ]
        , column
            [ width (fillPortion 9)
            , alignTop
            ]
            [ viewResultList model ]
        ]
    ]


viewSearchResultsDesktop : Model -> Element Msg
viewSearchResultsDesktop model =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            ]
            [ viewSearchBarSection model
            , viewSearchResultsSection model
            ]
        ]


viewSearchContentMobile : Model -> Element Msg
viewSearchContentMobile model =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width minMaxFillMobile
            , height fill
            , centerX
            ]
            [ row
                [ width fill
                , height (px 60)
                ]
                [ text "Search Top mobile!" ]
            ]
        ]


viewSearchBody : Model -> List (Html.Html Msg)
viewSearchBody model =
    let
        device =
            model.viewingDevice

        deviceView =
            case device.class of
                Phone ->
                    viewSearchContentMobile

                _ ->
                    viewSearchDesktop

        message =
            LanguageSelectChanged

        langOptions =
            languageOptionsForDisplay

        currentLanguage =
            model.language
    in
    layoutBody message langOptions (deviceView model) device currentLanguage
