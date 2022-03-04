module Page.UI.ProbeResponse exposing (..)

import Element exposing (Element, el, height, px, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..))


hasActionableProbeResponse : Response ProbeData -> Bool
hasActionableProbeResponse probeResponse =
    case probeResponse of
        Response d ->
            if d.totalItems > 0 then
                True

            else
                False

        -- We set this to true if the probe data is loading so that we do not falsely
        -- state that no results were available.
        Loading _ ->
            True

        -- If it hasn't been asked, then we don't know, so we assume it's actionable.
        NoResponseToShow ->
            True

        _ ->
            False


viewProbeResponseNumbers : Language -> Response ProbeData -> Element msg
viewProbeResponseNumbers language probeResponse =
    case probeResponse of
        Response data ->
            let
                formattedNumber =
                    toFloat data.totalItems
                        |> formatNumberByLanguage language

                textMsg =
                    extractLabelFromLanguageMap language localTranslations.resultsWithFilters
            in
            el
                []
                (text <| textMsg ++ ": " ++ formattedNumber)

        Loading _ ->
            el
                [ width (px 25)
                , height (px 25)
                ]
                (animatedLoader <| spinnerSvg colourScheme.slateGrey)

        Error errMsg ->
            el
                []
                (text <| extractLabelFromLanguageMap language localTranslations.errorLoadingProbeResults ++ ": " ++ errMsg)

        NoResponseToShow ->
            el
                []
                (text "")
