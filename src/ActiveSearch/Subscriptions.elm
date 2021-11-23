module ActiveSearch.Subscriptions exposing (..)

import Dict
import Msg exposing (Msg)
import Page
import Page.UI.Facets.RangeSlider as RangeSlider


subscriptions : Page.Model -> Sub Msg
subscriptions pageModel =
    let
        activeSearch =
            pageModel.activeSearch

        sliders =
            activeSearch.sliders

        sliderSubscriptions =
            Dict.toList sliders
                |> List.map
                    (\( k, v ) ->
                        RangeSlider.subscriptions v
                            |> Sub.map (Msg.UserMovedRangeSlider k)
                    )
    in
    Sub.batch sliderSubscriptions
