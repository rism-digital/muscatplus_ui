module Page.UI.ProbeResponse exposing (..)

import Element exposing (Element, el, height, px, text, width)
import Language exposing (Language, formatNumberByLanguage)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..))


viewProbeResponseNumbers : Language -> Response ProbeData -> Element msg
viewProbeResponseNumbers language probeResponse =
    case probeResponse of
        Response data ->
            let
                formattedNumber =
                    toFloat data.totalItems
                        |> formatNumberByLanguage language
            in
            el
                []
            <|
                text ("Results with filters applied: " ++ formattedNumber)

        Loading _ ->
            el
                [ width (px 25)
                , height (px 25)
                ]
                (animatedLoader <|
                    spinnerSvg colourScheme.slateGrey
                )

        Error errMsg ->
            el
                []
            <|
                text ("Error loading probe results: " ++ errMsg)

        NoResponseToShow ->
            el
                []
                (text "")
