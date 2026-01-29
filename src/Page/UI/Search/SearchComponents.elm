module Page.UI.Search.SearchComponents exposing (SearchButtonConfig, hasActionableProbeResponse, hasActionableQueryValidation, queryValidationState, viewProbeResponseNumbers, viewSearchButtons)

import Config as C
import Element exposing (Element, above, alignRight, column, el, fill, height, htmlAttribute, none, onLeft, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractLabelFromLanguageMapWithVariables, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (ProbeStatus(..), QueryValidation(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (buttonBaseStyles, headingSM)
import Page.UI.Errors exposing (createErrorMessage, errorMessageString)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.SearchTemplate exposing (controlsTmpl)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


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
    , userClickedOpenDownloaderMsg : msg
    , userClickedCloseDownloaderMsg : msg
    }


queryValidationState : ProbeStatus -> QueryValidation
queryValidationState probeResponse =
    case probeResponse of
        Probing ->
            CheckingQuery

        ProbeSuccess d ->
            d.queryStatus

        _ ->
            NotCheckedQuery


hasActionableQueryValidation : ProbeStatus -> Bool
hasActionableQueryValidation probeResponse =
    let
        qvState =
            queryValidationState probeResponse
    in
    case qvState of
        ValidQuery ->
            True

        EmptyQuery ->
            True

        NotCheckedQuery ->
            True

        _ ->
            False


hasActionableProbeResponse : ProbeStatus -> Bool
hasActionableProbeResponse probeResponse =
    case probeResponse of
        ProbeSuccess d ->
            d.totalItems > 0

        _ ->
            False


numberOfResults : ProbeStatus -> Maybe Int
numberOfResults probeResponse =
    case probeResponse of
        ProbeSuccess d ->
            Just d.totalItems

        _ ->
            Nothing


viewProbeResponseNumbers : Language -> ProbeStatus -> Element msg
viewProbeResponseNumbers language probeResponse =
    case probeResponse of
        Probing ->
            el
                [ width (px 25)
                , height (px 25)
                ]
                (animatedLoader
                    [ width (px 25)
                    , height (px 25)
                    ]
                    (spinnerSvg colourScheme.midGrey)
                )

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
            text textMsg

        ProbeError err ->
            createErrorMessage err
                |> errorMessageString language
                |> text

        NotChecked ->
            none


viewSearchButtons :
    SearchButtonConfig model msg
    -> Element msg
viewSearchButtons { language, model, isFrontPage, submitLabel, submitMsg, resetMsg, userClickedOpenDownloaderMsg } =
    let
        actionableProbeResponse =
            hasActionableProbeResponse model.probeResponse

        ( submitButtonColours, submitButtonMsg, submitPointerStyle ) =
            if model.applyFilterPrompt && actionableProbeResponse then
                ( colourScheme.lightBlue
                , Just submitMsg
                , pointer
                )

            else
                ( colourScheme.midGrey
                , Nothing
                , htmlAttribute (HA.style "cursor" "not-allowed")
                )

        -- never show the 'needs update' message on the front page, since it doesn't really
        -- make sense.
        updateMessage =
            viewIf
                (viewUpdateMessage submitButtonMsg language model.applyFilterPrompt actionableProbeResponse)
                (not isFrontPage)

        downloadButton =
            viewIf
                (column
                    [ alignRight ]
                    [ viewDownloadButton
                        { language = language
                        , model = model
                        , userClickedOpenDownloaderMsg = userClickedOpenDownloaderMsg
                        }
                    ]
                )
                (not isFrontPage)
    in
    controlsTmpl
        [ column
            [ width shrink
            ]
            [ Input.button
                (Border.color submitButtonColours
                    :: Background.color submitButtonColours
                    :: Font.color colourScheme.white
                    :: submitPointerStyle
                    :: buttonBaseStyles
                )
                { label = text (extractLabelFromLanguageMap language submitLabel)
                , onPress = submitButtonMsg
                }
            ]
        , column
            [ width fill ]
            [ row
                [ width fill
                , spacing 8
                ]
                [ el
                    [ Font.medium
                    , headingSM
                    ]
                    (viewProbeResponseNumbers language model.probeResponse)
                , updateMessage
                ]
            ]
        , downloadButton
        , column
            [ width shrink
            , alignRight
            ]
            [ Input.button
                [ Font.color colourScheme.lightBlue
                ]
                { label = text (extractLabelFromLanguageMap language localTranslations.resetAll)
                , onPress = Just resetMsg
                }
            ]
        ]


viewUpdateMessage : Maybe msg -> Language -> Bool -> Bool -> Element msg
viewUpdateMessage submitMsg language applyFilterPrompt actionableProbResponse =
    viewIf
        (Input.button
            (Background.color colourScheme.turquoise
                :: Font.color colourScheme.white
                :: buttonBaseStyles
            )
            { label = text (extractLabelFromLanguageMap language localTranslations.applyFiltersToUpdateResults)
            , onPress = submitMsg
            }
        )
        (applyFilterPrompt && actionableProbResponse)


viewDownloadButton :
    { language : Language
    , model :
        { a
            | applyFilterPrompt : Bool
            , probeResponse : ProbeStatus
        }
    , userClickedOpenDownloaderMsg : msg
    }
    -> Element msg
viewDownloadButton { language, model, userClickedOpenDownloaderMsg } =
    let
        downloadButtonMsg =
            if model.applyFilterPrompt then
                Nothing

            else
                numberOfResults model.probeResponse
                    |> Maybe.map (\c -> c <= C.csvDownloadMaximumRecords)
                    |> Maybe.andThen
                        (\isTrue ->
                            if isTrue then
                                Just userClickedOpenDownloaderMsg

                            else
                                Nothing
                        )

        buttonTheme =
            case downloadButtonMsg of
                Just _ ->
                    { background = colourScheme.puce
                    , borderColour = colourScheme.darkBlue
                    , cursor = pointer
                    , fontColour = colourScheme.white
                    , helpTooltip =
                        tooltip above none
                    }

                Nothing ->
                    let
                        formattedNumber =
                            toFloat C.csvDownloadMaximumRecords
                                |> formatNumberByLanguage language

                        tooltipMessage =
                            extractLabelFromLanguageMapWithVariables language
                                [ LanguageMapReplacementVariable "numResults" formattedNumber ]
                                localTranslations.downloadsLimited
                                |> text
                    in
                    { background = colourScheme.midGrey
                    , borderColour = colourScheme.darkGrey
                    , cursor = htmlAttribute (HA.style "cursor" "not-allowed")
                    , fontColour = colourScheme.white
                    , helpTooltip =
                        el tooltipStyle tooltipMessage
                            |> tooltip onLeft
                    }
    in
    Input.button
        (Border.color buttonTheme.borderColour
            :: Border.width 1
            :: Background.color buttonTheme.background
            :: Font.color buttonTheme.fontColour
            :: buttonTheme.cursor
            :: buttonTheme.helpTooltip
            :: buttonBaseStyles
        )
        { label = text (extractLabelFromLanguageMap language localTranslations.downloadResults)
        , onPress = downloadButtonMsg
        }
