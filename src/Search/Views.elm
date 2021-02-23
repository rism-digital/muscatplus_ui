module Search.Views exposing (viewSearchBody)

import Api.Search exposing (SearchQueryArgs)
import Element exposing (..)
import Element.Input as Input
import Html
import Html.Attributes
import Search.DataTypes exposing (Model, Msg(..), Route(..))
import UI.Layout exposing (layoutBody)
import UI.Style as Style exposing (greyBackground, minMaxFillDesktop, minMaxFillMobile, roundedBorder, roundedButton)


viewSearchDesktop : Model -> Element Msg
viewSearchDesktop model =
    case model.currentRoute of
        FrontPageRoute ->
            viewSearchFrontDesktop model

        SearchPageRoute ->
            viewSearchResultsDesktop model

        NotFound ->
            viewNotFound


viewNotFound : Element Msg
viewNotFound =
    row [] [ text "Route not found" ]


viewSearchFrontDesktop : Model -> Element Msg
viewSearchFrontDesktop model =
    row [ width fill, height fill ]
        [ column [ width fill, height fill, centerX, centerY ]
            [ row [ width fill, height (px 60), centerX, centerY ]
                [ column [ width minMaxFillDesktop, height fill, centerX, centerY ]
                    [ row [ width fill, height fill, centerX, centerY ]
                        [ text "Search RISM Online" ]
                    ]
                ]
            , row [ width fill, height (px 120), greyBackground, centerX, centerY ]
                [ column [ width minMaxFillDesktop, height fill, centerX ]
                    [ viewSearchKeywordInput model ]
                ]
            ]
        ]


viewSearchKeywordInput : Model -> Element Msg
viewSearchKeywordInput model =
    let
        queryObj =
            model.query
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
                ]
                { onChange = \inp -> SearchInput (SearchQueryArgs inp [] "")
                , placeholder = Just (Input.placeholder [] (text "Enter your query"))
                , text = queryObj.query
                , label = Input.labelHidden "Search"
                }
            ]
        , column [ width (fillPortion 2) ]
            [ Input.button (List.concat [ roundedButton, [] ])
                { onPress = Just NoOp
                , label = text "Search"
                }
            ]
        ]


viewSearchResultsDesktop : Model -> Element Msg
viewSearchResultsDesktop model =
    row [ width fill, height fill ]
        [ column [ width fill, height fill, centerX ]
            [ row [ width fill, height (px 120), greyBackground ]
                [ column [ width minMaxFillDesktop, height fill, centerX ]
                    [ viewSearchKeywordInput model
                    ]
                ]
            , row [ width fill, height fill, alignTop ]
                [ column [ width minMaxFillDesktop, height fill, centerX, alignTop ]
                    [ row [ width fill, alignTop, paddingXY 0 20 ]
                        [ column [ width (fillPortion 3) ] [ text "Sidebar" ]
                        , column [ width (fillPortion 9) ] [ text "Body" ]
                        ]
                    ]
                ]
            ]
        ]


viewSearchContentMobile : Model -> Element Msg
viewSearchContentMobile model =
    row [ width fill, height fill ]
        [ column [ width minMaxFillMobile, height fill, centerX ]
            [ row [ width fill, height (px 60) ]
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
    in
    layoutBody (deviceView model) device
