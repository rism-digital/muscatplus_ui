module Page.Front.Views.SearchControls exposing (..)

import Element exposing (Element, alignLeft, alignRight, alignTop, centerY, column, el, fill, fillPortion, height, htmlAttribute, none, paddingXY, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.UI.Attributes exposing (headingLG, headingSM, lineSpacing, sectionSpacing)
import Page.UI.Events exposing (onEnter)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..))


frontKeywordQueryInputView :
    Language
    ->
        { submitMsg : msg
        , changeMsg : String -> msg
        }
    -> String
    -> Element msg
frontKeywordQueryInputView language msgs queryText =
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignRight
            , spacing sectionSpacing
            ]
            [ row
                [ width fill
                , spacing lineSpacing
                ]
                [ column
                    [ width <| fillPortion 6 ]
                    [ Input.text
                        [ width fill
                        , height (px 60)
                        , centerY
                        , htmlAttribute (HA.autocomplete False)
                        , Border.rounded 0
                        , onEnter msgs.submitMsg
                        , headingLG
                        , paddingXY 10 20
                        ]
                        { onChange = \inp -> msgs.changeMsg inp
                        , placeholder = Just (Input.placeholder [ height fill ] <| el [ centerY ] (text (extractLabelFromLanguageMap language localTranslations.queryEnter)))
                        , text = queryText
                        , label = Input.labelHidden (extractLabelFromLanguageMap language localTranslations.search)
                        }
                    ]
                ]
            ]
        ]


updateMessageView : Language -> Element FrontMsg
updateMessageView language =
    el
        [ width fill
        , height (px 30)
        , headingSM
        , Font.bold
        ]
        (text "Apply filters to update search results")


viewProbeResponseNumbers : Language -> Response ProbeData -> Element FrontMsg
viewProbeResponseNumbers language probeResponse =
    let
        message =
            case probeResponse of
                Response data ->
                    let
                        formattedNumber =
                            toFloat data.totalItems
                                |> formatNumberByLanguage language
                    in
                    "Results with filters applied: " ++ formattedNumber

                Loading _ ->
                    "Loading results preview... "

                Error _ ->
                    "Error loading probe results"

                NoResponseToShow ->
                    ""
    in
    el
        [ headingSM ]
        (text message)


viewFrontSearchButtons : Language -> FrontPageModel -> Element FrontMsg
viewFrontSearchButtons language model =
    let
        msgs =
            { submitMsg = FrontMsg.UserTriggeredSearchSubmit
            , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
            , resetMsg = FrontMsg.UserResetAllFilters
            }
    in
    row
        [ width fill
        , height (px 60)
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
                        [ Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                        , Background.color (colourScheme.darkBlue |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 60)
                        , width (px 120)
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        ]
                        { onPress = Just msgs.submitMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.search)
                        }
                    ]
                , column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color (colourScheme.midGrey |> convertColorToElementColor)
                        , Background.color (colourScheme.midGrey |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 60)
                        , width (px 120)
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        ]
                        { onPress = Just msgs.resetMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.resetAll)
                        }
                    ]
                , column
                    [ width fill ]
                    [ viewIf (viewUpdateMessage language) model.applyFilterPrompt
                    , viewProbeResponseNumbers language model.probeResponse
                    ]
                ]
            ]
        ]
