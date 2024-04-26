module Page.UI.Search.SearchComponents exposing (SearchButtonConfig, hasActionableProbeResponse, viewSearchButtons)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, minimum, none, padding, paddingXY, paragraph, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Error.Views exposing (createProbeErrorMessage)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingLG, lineSpacing)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..))


type alias SearchButtonConfig a msg =
    { language : Language
    , model :
        { a
            | probeResponse : Response ProbeData
            , applyFilterPrompt : Bool
        }
    , isFrontPage : Bool
    , submitLabel : LanguageMap
    , submitMsg : msg
    , resetMsg : msg
    }


hasActionableProbeResponse : Response ProbeData -> Bool
hasActionableProbeResponse probeResponse =
    case probeResponse of
        Loading _ ->
            True

        -- We set this to true if the probe data is loading so that we do not falsely
        -- state that no results were available.
        Response d ->
            d.totalItems > 0

        -- If it hasn't been asked, then we don't know, so we assume it's actionable.
        NoResponseToShow ->
            True

        _ ->
            False


viewProbeResponseNumbers : Language -> Response ProbeData -> Element msg
viewProbeResponseNumbers language probeResponse =
    case probeResponse of
        Loading _ ->
            el
                [ width (px 25)
                , height (px 25)
                ]
                (animatedLoader [ width (px 25), height (px 25) ] (spinnerSvg colourScheme.midGrey))

        Response data ->
            let
                formattedNumber =
                    toFloat data.totalItems
                        |> formatNumberByLanguage language

                textMsg =
                    if formattedNumber == "0" then
                        extractLabelFromLanguageMap language localTranslations.noResultsWouldBeFound

                    else
                        extractLabelFromLanguageMap language localTranslations.numberOfResults
                            ++ ": "
                            ++ formattedNumber
            in
            el
                [ Font.medium
                , headingLG
                ]
                (text textMsg)

        Error errMsg ->
            paragraph
                [ Font.medium
                , headingLG
                ]
                [ extractLabelFromLanguageMap language localTranslations.errorLoadingProbeResults
                    ++ ": "
                    ++ createProbeErrorMessage errMsg
                    |> text
                ]

        NoResponseToShow ->
            none


viewSearchButtons :
    SearchButtonConfig model msg
    -> Element msg
viewSearchButtons { language, model, isFrontPage, submitLabel, submitMsg, resetMsg } =
    let
        actionableProbeResponse =
            hasActionableProbeResponse model.probeResponse

        ( submitButtonColours, submitButtonMsg, submitPointerStyle ) =
            if model.applyFilterPrompt && actionableProbeResponse then
                ( colourScheme.lightBlue
                , Just submitMsg
                , pointer
                )

            else if isFrontPage then
                ( colourScheme.lightBlue
                , Just submitMsg
                , pointer
                )

            else
                ( colourScheme.midGrey
                , Nothing
                , htmlAttribute (HA.style "cursor" "not-allowed")
                )

        submitButtonLabel =
            if isFrontPage then
                extractLabelFromLanguageMap language localTranslations.showAllRecords

            else
                extractLabelFromLanguageMap language submitLabel

        -- never show the 'needs update' message on the front page, since it doesn't really
        -- make sense.
        updateMessage =
            viewIf
                (viewUpdateMessage submitButtonMsg language model.applyFilterPrompt actionableProbeResponse)
                isFrontPage
    in
    row
        (alignTop
            :: Background.color colourScheme.lightGrey
            :: width fill
            :: height (px 50)
            :: paddingXY 20 0
            :: centerY
            :: Border.color colourScheme.darkBlue
            :: Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            :: []
        )
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
                        , padding 10
                        , height (px 35)
                        , width (shrink |> minimum 120)
                        , Font.center
                        , Font.color colourScheme.white
                        , headingLG
                        , submitPointerStyle
                        , centerY
                        ]
                        { label = text submitButtonLabel
                        , onPress = submitButtonMsg
                        }
                    ]
                , column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color colourScheme.turquoise
                        , Background.color colourScheme.turquoise
                        , padding 10
                        , height (px 35)
                        , width (shrink |> minimum 120)
                        , Font.center
                        , Font.color colourScheme.white
                        , centerY
                        , headingLG
                        ]
                        { label = text (extractLabelFromLanguageMap language localTranslations.resetAll)
                        , onPress = Just resetMsg
                        }
                    ]
                , column
                    [ width fill ]
                    [ row
                        [ width fill
                        , spacing 5
                        ]
                        [ viewProbeResponseNumbers language model.probeResponse
                        , updateMessage
                        ]
                    ]
                ]
            ]
        ]


viewUpdateMessage : Maybe msg -> Language -> Bool -> Bool -> Element msg
viewUpdateMessage submitMsg language applyFilterPrompt actionableProbResponse =
    (applyFilterPrompt && actionableProbResponse)
        |> viewIf
            (Input.button
                [ width shrink
                , padding 10
                , Background.color colourScheme.lightOrange
                , headingLG
                , Font.color colourScheme.white
                ]
                { label = text (extractLabelFromLanguageMap language localTranslations.applyFiltersToUpdateResults)
                , onPress = submitMsg
                }
            )
