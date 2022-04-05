module Page.Record.Views.InstitutionPage.SourceSearch exposing (..)

import Element exposing (Element, alignBottom, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, inFront, minimum, none, padding, paddingXY, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.Record.Views.Facets exposing (facetRecordMsgConfig)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), SourceResultBody)
import Page.Search.Views.Previews exposing (viewPreviewRouter)
import Page.Search.Views.Results exposing (resultIsSelected, resultTemplate)
import Page.Search.Views.Results.SourceResult exposing (viewSourceFlags, viewSourcePartOf, viewSourceSummary)
import Page.Search.Views.SearchControls exposing (viewSearchButtons, viewUpdateMessage)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingSM, lineSpacing, minimalDropShadow, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.ProbeResponse exposing (hasActionableProbeResponse, viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))


viewSourceSearchTab : Language -> RecordPageModel RecordMsg -> InstitutionBody -> Element RecordMsg
viewSourceSearchTab language model body =
    row
        [ width fill
        , height fill
        , alignTop
        , clipY
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ searchResultsViewRouter language model ]
        ]


searchResultsViewRouter : Language -> RecordPageModel RecordMsg -> Element RecordMsg
searchResultsViewRouter language model =
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection language model oldData True

        Loading _ ->
            viewSearchResultsLoading language model

        Response (SearchData body) ->
            viewSearchResultsSection language model body False

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoading language model

        _ ->
            viewSearchResultsError language model


viewSearchResultsLoading : Language -> RecordPageModel RecordMsg -> Element RecordMsg
viewSearchResultsLoading language model =
    none


viewSearchResultsError : Language -> RecordPageModel RecordMsg -> Element RecordMsg
viewSearchResultsError language model =
    none


viewSearchResultsSection : Language -> RecordPageModel RecordMsg -> SearchBody -> Bool -> Element RecordMsg
viewSearchResultsSection language model body isLoading =
    let
        renderedPreview =
            case model.preview of
                Loading Nothing ->
                    none

                Loading (Just oldData) ->
                    viewPreviewRouter language RecordMsg.UserClickedClosePreviewWindow oldData

                Response resp ->
                    viewPreviewRouter language RecordMsg.UserClickedClosePreviewWindow resp

                Error _ ->
                    none

                NoResponseToShow ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Border.widthEach { bottom = 0, top = 0, left = 0, right = 2 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            [ viewSearchResultsListPanel language model body isLoading
            , viewPagination language body.pagination RecordMsg.UserClickedSearchResultsPagination
            ]
        , column
            [ width fill
            , height fill
            , alignTop
            , inFront renderedPreview
            ]
            [ viewSearchControls language model body ]
        ]


viewSearchResultsListPanel : Language -> RecordPageModel RecordMsg -> SearchBody -> Bool -> Element RecordMsg
viewSearchResultsListPanel language model body isLoading =
    let
        loadingScreen =
            if isLoading then
                el
                    [ width fill
                    , height fill
                    , Background.color (colourScheme.translucentGrey |> convertColorToElementColor)
                    ]
                    (el
                        [ width (px 50)
                        , height (px 50)
                        , centerX
                        , centerY
                        ]
                        (animatedLoader [ width (px 50), height (px 50) ] <| spinnerSvg colourScheme.slateGrey)
                    )

            else
                none
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.id "search-results-list")
        ]
        [ column
            [ width fill
            , height shrink
            , alignTop
            , inFront loadingScreen
            ]
            [ viewSearchResultsList language model body ]
        ]


viewSearchResultsList : Language -> RecordPageModel RecordMsg -> SearchBody -> Element RecordMsg
viewSearchResultsList language model body =
    row
        [ width fill
        , height shrink
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            (List.map (\result -> viewSearchResultRouter language model.selectedResult result) body.items)
        ]


viewSearchResultRouter : Language -> Maybe String -> SearchResult -> Element RecordMsg
viewSearchResultRouter language selectedResult res =
    case res of
        SourceResult body ->
            viewSourceSearchResult language selectedResult body

        _ ->
            none


viewSourceSearchResult : Language -> Maybe String -> SourceResultBody -> Element RecordMsg
viewSourceSearchResult language selectedResult body =
    let
        resultColours =
            resultIsSelected selectedResult body.id

        resultBody =
            [ viewMaybe (viewSourceSummary language resultColours.iconColour) body.summary
            , viewMaybe (viewSourcePartOf language resultColours.fontLinkColour) body.partOf
            , viewMaybe (viewSourceFlags language) body.flags
            ]
    in
    resultTemplate
        { id = body.id
        , language = language
        , resultTitle = body.label
        , colours = resultColours
        , resultBody = resultBody
        , clickMsg = RecordMsg.UserClickedSearchResultForPreview
        }


viewSearchButtons : Language -> RecordPageModel RecordMsg -> Element RecordMsg
viewSearchButtons language model =
    let
        msgs =
            { submitMsg = RecordMsg.UserTriggeredSearchSubmit
            , changeMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
            , resetMsg = RecordMsg.UserResetAllFilters
            }

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
                , Just msgs.submitMsg
                , pointer
                )
    in
    row
        [ alignBottom
        , Background.color (colourScheme.white |> convertColorToElementColor)

        --, Border.color (colourScheme.lightGrey |> convertColorToElementColor)
        --, Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
        , minimalDropShadow
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
                        { onPress = Just msgs.resetMsg
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


viewFacetsForSourcesMode : Language -> RecordPageModel RecordMsg -> SearchBody -> Element RecordMsg
viewFacetsForSourcesMode language model body =
    let
        msgs =
            { submitMsg = RecordMsg.UserTriggeredSearchSubmit
            , changeMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
            }

        activeSearch =
            model.activeSearch

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , body = body
            , selectColumns = 3
            }
    in
    row
        [ padding 10
        , scrollbarY
        , width fill
        , alignTop
        , height fill
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , alignTop
            ]
            [ row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    [ searchKeywordInput language msgs qText ]
                ]
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ row
                    [ width fill
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet (facetConfig "composer") facetRecordMsgConfig ]
                    , column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet (facetConfig "people") facetRecordMsgConfig ]
                    ]
                ]
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ viewFacet (facetConfig "date-range") facetRecordMsgConfig
                ]

            --, viewFacetSection language
            --    [ viewFacetToggleSection language activeSearch body ]
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ viewFacet (facetConfig "source-type") facetRecordMsgConfig
                , viewFacet (facetConfig "content-types") facetRecordMsgConfig
                , viewFacet (facetConfig "material-group-types") facetRecordMsgConfig
                ]
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ viewFacet (facetConfig "text-language") facetRecordMsgConfig
                , viewFacet (facetConfig "format-extent") facetRecordMsgConfig
                ]

            --, viewFacet "date-range" language activeSearch body
            --, viewFacet "num-holdings" language activeSearch body
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ viewFacet (facetConfig "subjects") facetRecordMsgConfig ]
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ viewFacet (facetConfig "scoring") facetRecordMsgConfig ]
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ viewFacet (facetConfig "sigla") facetRecordMsgConfig ]

            --, viewFacet "holding-institution" language activeSearch body
            ]
        ]


viewSearchControls : Language -> RecordPageModel RecordMsg -> SearchBody -> Element RecordMsg
viewSearchControls language model body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ viewFacetsForSourcesMode language model body
            , viewSearchButtons language model
            ]
        ]
