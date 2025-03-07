module Page.UI.Search.SearchComponents exposing (SearchButtonConfig, hasActionableProbeResponse, hasActionableQueryValidation, queryValidationState, viewProbeResponseNumbers, viewSearchButtons)

import Config as C
import Element exposing (Element, above, alignRight, alignTop, centerY, column, el, fill, height, htmlAttribute, none, onLeft, padding, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractLabelFromLanguageMapWithVariables, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.RecordTypes.Probe exposing (ProbeStatus(..), QueryValidation(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingLG, headingMD, minimalDropShadow)
import Page.UI.Errors exposing (createErrorMessage)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (spinnerSvg)
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
            text textMsg

        ProbeError err ->
            createErrorMessage language err
                |> Tuple.first
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
                { label = text (extractLabelFromLanguageMap language submitLabel)
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
                [ el
                    [ Font.medium
                    , headingLG
                    ]
                    (viewProbeResponseNumbers language model.probeResponse)
                , updateMessage
                ]
            ]
        , column
            [ alignRight ]
            [ viewDownloadButton
                { language = language
                , model = model
                , userClickedOpenDownloaderMsg = userClickedOpenDownloaderMsg
                }
            ]
        ]


viewUpdateMessage : Maybe msg -> Language -> Bool -> Bool -> Element msg
viewUpdateMessage submitMsg language applyFilterPrompt actionableProbResponse =
    viewIf
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
        (applyFilterPrompt && actionableProbResponse)


viewDownloadButton :
    { language : Language
    , model :
        { a
            | probeResponse : ProbeStatus
            , applyFilterPrompt : Bool
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

        formattedNumber =
            toFloat C.csvDownloadMaximumRecords
                |> formatNumberByLanguage language

        tooltipMessage =
            extractLabelFromLanguageMapWithVariables language
                [ LanguageMapReplacementVariable "numResults" formattedNumber ]
                localTranslations.downloadsLimited
                |> text

        buttonTheme =
            case downloadButtonMsg of
                Just _ ->
                    { background = colourScheme.puce
                    , cursor = pointer
                    , fontColour = colourScheme.white
                    , borderColour = colourScheme.darkBlue
                    , helpTooltip =
                        tooltip above none
                    }

                Nothing ->
                    { background = colourScheme.lightGrey
                    , cursor = htmlAttribute (HA.style "cursor" "not-allowed")
                    , fontColour = colourScheme.darkGrey
                    , borderColour = colourScheme.darkGrey
                    , helpTooltip =
                        el tooltipStyle tooltipMessage
                            |> tooltip onLeft
                    }
    in
    Input.button
        [ Border.color buttonTheme.borderColour
        , Border.width 1
        , Background.color buttonTheme.background
        , Font.color buttonTheme.fontColour
        , height (px 35)
        , paddingXY 10 0
        , buttonTheme.cursor
        , buttonTheme.helpTooltip
        ]
        { label = text "Download results"
        , onPress = downloadButtonMsg
        }
