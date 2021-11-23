module Subscriptions exposing (subscriptions)

import Browser.Events exposing (onResize)
import Device exposing (detectDevice)
import Dict
import Model exposing (Model)
import Msg exposing (Msg)
import Page.UI.Facets.RangeSlider as RangeSlider


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subBatch =
            Sub.batch
                [ onResize <|
                    \width height -> Msg.UserResizedWindow (detectDevice width height)
                ]
    in
    subBatch
