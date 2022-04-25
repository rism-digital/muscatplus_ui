module Page.UI.Search.SearchComponents exposing (..)

import Element exposing (Element, alignBottom, centerY, column, el, fill, height, htmlAttribute, minimum, none, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingSM, lineSpacing)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..))


hasActionableProbeResponse : Response ProbeData -> Bool
hasActionableProbeResponse probeResponse =
    case probeResponse of
        Response d ->
            d.totalItems > 0

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
                (animatedLoader [ width (px 25), height (px 25) ] <| spinnerSvg colourScheme.slateGrey)

        Error errMsg ->
            el
                []
                (text <| extractLabelFromLanguageMap language localTranslations.errorLoadingProbeResults ++ ": " ++ errMsg)

        NoResponseToShow ->
            el
                []
                (text "")


viewUpdateMessage : Language -> Bool -> Bool -> Element msg
viewUpdateMessage language applyFilterPrompt actionableProbResponse =
    let
        elMsg =
            if applyFilterPrompt && actionableProbResponse then
                text <| extractLabelFromLanguageMap language localTranslations.applyFiltersToUpdateResults

            else if applyFilterPrompt && not actionableProbResponse then
                text <| extractLabelFromLanguageMap language localTranslations.noResultsWouldBeFound

            else
                none
    in
    el
        [ width fill
        , height (px 30)
        , headingSM
        , Font.bold
        ]
        elMsg


type alias SearchButtonConfig a msg =
    { language : Language
    , model : { a | probeResponse : Response ProbeData, applyFilterPrompt : Bool }
    , submitMsg : msg
    , resetMsg : msg
    }


viewSearchButtons :
    SearchButtonConfig model msg
    -> Element msg
viewSearchButtons { language, model, submitMsg, resetMsg } =
    let
        actionableProbeResponse =
            hasActionableProbeResponse model.probeResponse

        disableSubmitButton =
            not <| actionableProbeResponse

        ( submitButtonColours, submitButtonMsg, submitPointerStyle ) =
            if disableSubmitButton then
                ( colourScheme.midGrey |> convertColorToElementColor
                , Nothing
                , htmlAttribute (HA.style "cursor" "not-allowed")
                )

            else
                ( colourScheme.darkBlue |> convertColorToElementColor
                , Just submitMsg
                , pointer
                )
    in
    row
        [ alignBottom
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , Border.widthEach { top = 1, bottom = 0, left = 0, right = 1 }
        , width fill
        , height (px 100)
        , paddingXY 20 0
        , centerY
        ]
        [ column
            [ width fill
            , height fill
            , centerY
            ]
            [ row
                [ width fill
                , height fill
                , spacing lineSpacing
                , centerY
                ]
                [ column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color submitButtonColours
                        , Background.color submitButtonColours
                        , paddingXY 10 10
                        , height (px 60)
                        , width (shrink |> minimum 120)
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        , submitPointerStyle
                        ]
                        { onPress = submitButtonMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.applyFilters)
                        }
                    ]
                , column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color (colourScheme.turquoise |> convertColorToElementColor)
                        , Background.color (colourScheme.turquoise |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 60)
                        , width (shrink |> minimum 120)
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        ]
                        { onPress = Just resetMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.resetAll)
                        }
                    ]
                , column
                    [ width fill ]
                    [ viewUpdateMessage language model.applyFilterPrompt actionableProbeResponse
                    , viewProbeResponseNumbers language model.probeResponse
                    ]
                ]
            ]
        ]
