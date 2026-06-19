module Page.UI.Record.PublicationWorksSearch exposing
    ( Layout(..)
    , viewPublicationWorksSearchControls
    )

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Attribute, Element, alignRight, centerX, centerY, column, fill, fillPortion, htmlAttribute, none, pointer, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.UI.Attributes exposing (buttonBaseStyles, headingSM)
import Page.UI.Facets.KeywordQuery exposing (viewKeywordQueryInput)
import Page.UI.Search.SearchComponents exposing (hasActionableQueryValidation, queryValidationState, viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme)


type Layout
    = Inline
    | Stacked


viewPublicationWorksSearchControls :
    { activeSearch : ActiveSearch msg
    , clearMsg : msg
    , changeMsg : String -> msg
    , disabledSubmitMsg : msg
    , enabledSubmitMsg : msg
    , language : Language
    , layout : Layout
    , probeResponse : ProbeStatus
    , userClickedOpenQueryBuilderMsg : msg
    }
    -> Element msg
viewPublicationWorksSearchControls { activeSearch, clearMsg, changeMsg, disabledSubmitMsg, enabledSubmitMsg, language, layout, probeResponse, userClickedOpenQueryBuilderMsg } =
    let
        canSubmit =
            hasActionableQueryValidation probeResponse

        queryText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        searchButton =
            Input.button
                (buttonStyles canSubmit)
                { label = extractLabelFromLanguageMap language localTranslations.search |> text
                , onPress =
                    if canSubmit then
                        Just enabledSubmitMsg

                    else
                        Nothing
                }

        queryValidation =
            queryValidationState probeResponse

        submitMsg =
            if canSubmit then
                enabledSubmitMsg

            else
                disabledSubmitMsg

        inputField =
            viewKeywordQueryInput
                { language = language
                , submitMsg = submitMsg
                , changeMsg = changeMsg
                , queryText = queryText
                , queryIsValid = queryValidation
                , userClickedOpenQueryBuilderMsg = userClickedOpenQueryBuilderMsg
                , suppressQueryBuilderButton = True
                }

        resultSummary =
            row
                [ width fill
                ]
                [ column
                    [ width (fillPortion 1) ]
                    [ row
                        [ spacing 8, width fill, alignRight ]
                        [ Input.button
                            [ Font.color colourScheme.lightBlue ]
                            { label = text "Clear search"
                            , onPress =
                                if String.isEmpty queryText then
                                    Nothing

                                else
                                    Just clearMsg
                            }
                        , column
                            [ Font.medium
                            , headingSM
                            ]
                            [ viewProbeResponseNumbers language probeResponse ]
                        , column
                            [ alignRight ]
                            [ searchButton ]
                        ]
                    ]
                ]
    in
    case layout of
        Inline ->
            centeredInlineControls
                [ inputField
                , resultSummary
                ]

        Stacked ->
            column
                [ width fill
                , spacing 12
                ]
                [ inputField
                , row [ width fill ] [ column [ alignRight, centerY ] [ searchButton ] ]
                , resultSummary
                ]


centeredInlineControls : List (Element msg) -> Element msg
centeredInlineControls content =
    row
        [ width fill
        ]
        [ column
            [ width (fillPortion 1) ]
            [ none ]
        , column
            [ width (fillPortion 2)
            , centerX
            ]
            content
        , column
            [ width (fillPortion 1) ]
            [ none ]
        ]


buttonStyles : Bool -> List (Attribute msg)
buttonStyles canSubmit =
    let
        backgroundColor =
            if canSubmit then
                colourScheme.lightBlue

            else
                colourScheme.midGrey

        cursorStyle =
            if canSubmit then
                pointer

            else
                htmlAttribute (HA.style "cursor" "not-allowed")
    in
    Border.color backgroundColor
        :: Background.color backgroundColor
        :: Font.color colourScheme.white
        :: cursorStyle
        :: centerY
        :: buttonBaseStyles
