module Search.Views.View exposing (viewSearchBody)

import Element exposing (..)
import Element.Border as Border
import Element.Input as Input
import Html
import Html.Attributes
import Search.DataTypes exposing (ApiResponse(..), Model, Msg(..), Route(..))
import Search.Views.Facets exposing (viewSidebarFacets, viewTypeFacet)
import Search.Views.Results exposing (viewResultList)
import Search.Views.Shared exposing (onEnter)
import Shared.Language exposing (Language, extractLabelFromLanguageMap, languageOptionsForDisplay, localTranslations)
import UI.Layout exposing (layoutBody)
import UI.Style as Style exposing (darkBlue, greyBackground, lightBlue, minMaxFillDesktop, minMaxFillMobile, roundedBorder, roundedButton)


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
                    , centerY
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
        , centerY
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
                , height (px 50)
                , Border.widthEach { bottom = 1, top = 1, left = 1, right = 0 }
                , Border.roundEach { topLeft = 5, bottomLeft = 5, topRight = 0, bottomRight = 0 }
                , htmlAttribute (Html.Attributes.autocomplete False)
                , Border.color lightBlue
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
            [ Input.button
                [ Border.widthEach { bottom = 1, top = 1, left = 0, right = 1 }
                , Border.roundEach { topLeft = 0, bottomLeft = 0, topRight = 5, bottomRight = 5 }
                , Border.color lightBlue
                , paddingXY 10 10
                , height (px 50)
                , width shrink
                ]
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

        viewResults =
            case resp of
                Response searchResponse ->
                    viewHasSearchResults model

                ApiError ->
                    viewSearchResultsError model

                Loading ->
                    viewSearchResultsLoading model

                _ ->
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


viewSearchResultsError : Model -> List (Element Msg)
viewSearchResultsError model =
    [ row
        [ width fill ]
        [ text model.errorMessage ]
    ]


viewHasNoSearchResults : Model -> List (Element Msg)
viewHasNoSearchResults model =
    [ row
        [ width fill ]
        [ text "No results were returned" ]
    ]


viewSearchResultsLoading : Model -> List (Element Msg)
viewSearchResultsLoading model =
    [ row
        [ width fill ]
        [ text "Loading results" ]
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
