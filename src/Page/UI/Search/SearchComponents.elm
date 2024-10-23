module Page.UI.Search.SearchComponents exposing (SearchButtonConfig, hasActionableProbeResponse, queryValidationState, viewSearchButtons)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (ProbeData, ProbeStatus(..), QueryValidation(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingLG, headingMD, minimalDropShadow)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme)


type alias SearchButtonConfig a msg =
    { language : Language
    , model :
        { a
            | probeResponse : ProbeStatus
            , applyFilterPrompt : Bool
        }
    , isFrontPage : Bool
    , submitLabel : LanguageMap
    , submitMsg : msg
    , resetMsg : msg
    }


queryValidationState : ProbeStatus -> QueryValidation
queryValidationState probeResponse =
    case probeResponse of
        ProbeSuccess d ->
            if d.validQuery then
                ValidQuery

            else
                InvalidQuery

        _ ->
            NotCheckedQuery


hasActionableProbeResponse : ProbeStatus -> Bool
hasActionableProbeResponse probeResponse =
    case probeResponse of
        ProbeSuccess d ->
            d.totalItems > 0

        _ ->
            False


viewProbeResponseNumbers : Language -> ProbeStatus -> Element msg
viewProbeResponseNumbers language probeResponse =
    case probeResponse of
        Probing ->
            el
                [ width (px 25)
                , height (px 25)
                ]
                (animatedLoader [ width (px 25), height (px 25) ] (spinnerSvg colourScheme.midGrey))

        ProbeSuccess data ->
            let
                textMsg =
                    if data.totalItems == 0 then
                        extractLabelFromLanguageMap language localTranslations.noResultsWouldBeFound

                    else
                        let
                            probeLabel number =
                                extractLabelFromLanguageMap language localTranslations.numberOfResults
                                    ++ ": "
                                    ++ number
                        in
                        toFloat data.totalItems
                            |> formatNumberByLanguage language
                            |> probeLabel
            in
            el
                [ Font.medium
                , headingLG
                ]
                (text textMsg)

        _ ->
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
        [ alignTop
        , Background.color colourScheme.lightGrey
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color colourScheme.midGrey
        , minimalDropShadow
        , htmlAttribute (HA.style "clip-path" "inset(0px 0px -5px 0px)")
        , htmlAttribute (HA.style "z-index" "10")
        , width fill
        , height
            (if isFrontPage then
                px 85

             else
                px 50
            )
        , spacing 12
        , centerY
        , paddingXY 20 0
        ]
        [ column
            [ width shrink
            ]
            [ Input.button
                [ Border.color submitButtonColours
                , Background.color submitButtonColours
                , height (px 35)
                , width shrink
                , Font.center
                , Font.color colourScheme.white
                , headingMD
                , submitPointerStyle
                , centerY
                , paddingXY 10 0
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
                , height (px 35)
                , width shrink
                , Font.center
                , Font.color colourScheme.white
                , centerY
                , headingMD
                , paddingXY 10 0
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
