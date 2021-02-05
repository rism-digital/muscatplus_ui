module Search.Views exposing (viewSearchBody)

import Element exposing (..)
import Html
import Search.DataTypes exposing (Model, Msg(..))
import UI.Layout exposing (layoutBody)
import UI.Style exposing (minMaxFillDesktop, minMaxFillMobile)


viewSearchContentDesktop : Model -> Element Msg
viewSearchContentDesktop model =
    row [ width fill, height fill ]
        [ column [ width minMaxFillDesktop, height fill, centerX ]
            [ row [ width fill, height (px 120) ]
                [ text "Search Top!" ]
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
                    viewSearchContentDesktop
    in
    layoutBody (deviceView model)
