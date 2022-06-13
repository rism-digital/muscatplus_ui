module Page.UI.Search.SearchComponents exposing (..)

import Element exposing (Element, alignBottom, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, minimum, none, padding, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingMD, headingSM, lineSpacing, minimalDropShadow)
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
                    if formattedNumber == "0" then
                        extractLabelFromLanguageMap language localTranslations.noResultsWouldBeFound

                    else
                        extractLabelFromLanguageMap language localTranslations.resultsWithFilters
                            ++ ": "
                            ++ formattedNumber
            in
            el
                [ Font.medium
                , headingMD
                ]
                (text <| textMsg)

        Loading _ ->
            el
                [ width (px 25)
                , height (px 25)
                ]
                (animatedLoader [ width (px 25), height (px 25) ] <| spinnerSvg colourScheme.slateGrey)

        Error errMsg ->
            el
                [ Font.medium ]
                (text <| extractLabelFromLanguageMap language localTranslations.errorLoadingProbeResults ++ ": " ++ errMsg)

        NoResponseToShow ->
            none


viewUpdateMessage : Language -> Bool -> Bool -> Element msg
viewUpdateMessage language applyFilterPrompt actionableProbResponse =
    if applyFilterPrompt && actionableProbResponse then
        el
            [ width shrink
            , padding 5
            , Border.width 1
            , Border.color (colourScheme.white |> convertColorToElementColor)
            , Background.color (colourScheme.lightOrange |> convertColorToElementColor)
            , headingSM
            , Font.bold
            , Font.color (colourScheme.white |> convertColorToElementColor)
            ]
            (text <| extractLabelFromLanguageMap language localTranslations.applyFiltersToUpdateResults)

    else
        none


type alias SearchButtonConfig a msg =
    { language : Language
    , model : { a | probeResponse : Response ProbeData, applyFilterPrompt : Bool }
    , isFrontPage : Bool
    , submitLabel : LanguageMap
    , submitMsg : msg
    , resetMsg : msg
    }


viewSearchButtons :
    SearchButtonConfig model msg
    -> Element msg
viewSearchButtons { language, model, isFrontPage, submitLabel, submitMsg, resetMsg } =
    let
        actionableProbeResponse =
            hasActionableProbeResponse model.probeResponse

        ( submitButtonColours, submitButtonMsg, submitPointerStyle ) =
            if model.applyFilterPrompt && actionableProbeResponse then
                ( colourScheme.lightBlue |> convertColorToElementColor
                , Just submitMsg
                , pointer
                )

            else if isFrontPage then
                ( colourScheme.lightBlue |> convertColorToElementColor
                , Just submitMsg
                , pointer
                )

            else
                ( colourScheme.midGrey |> convertColorToElementColor
                , Nothing
                , htmlAttribute (HA.style "cursor" "not-allowed")
                )

        submitButtonLabel =
            if isFrontPage then
                extractLabelFromLanguageMap language localTranslations.showAllRecords

            else
                extractLabelFromLanguageMap language submitLabel
    in
    row
        [ alignTop
        , Background.color (colourScheme.lightGrey |> convertColorToElementColor)
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
        , width fill
        , height (px 50)
        , paddingXY 10 0
        , centerY
        , minimalDropShadow
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
                        , height (px 40)
                        , width (shrink |> minimum 120)
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        , submitPointerStyle
                        ]
                        { onPress = submitButtonMsg
                        , label = text submitButtonLabel
                        }
                    ]
                , column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color (colourScheme.turquoise |> convertColorToElementColor)
                        , Background.color (colourScheme.turquoise |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 40)
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
                    [ row
                        [ width fill
                        , spacing 5
                        ]
                        [ viewProbeResponseNumbers language model.probeResponse
                        , viewUpdateMessage language model.applyFilterPrompt actionableProbeResponse
                        ]
                    ]
                ]
            ]
        ]
