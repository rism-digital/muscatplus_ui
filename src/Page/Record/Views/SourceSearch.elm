module Page.Record.Views.SourceSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, inFront, none, padding, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg(..))
import Page.Record.Views.Facets exposing (facetRecordMsgConfig)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingSM, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText, h3, renderParagraph)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Record.Previews exposing (viewPreviewRouter)
import Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)
import Page.UI.Search.SearchComponents exposing (viewSearchButtons)
import Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))


viewSourceSearchTab :
    Language
    -> RecordPageModel RecordMsg
    -> Element RecordMsg
viewSourceSearchTab language model =
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


searchResultsViewRouter :
    Language
    -> RecordPageModel RecordMsg
    -> Element RecordMsg
searchResultsViewRouter language model =
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection language model oldData True

        Loading _ ->
            viewSearchResultsLoadingTmpl language

        Response (SearchData body) ->
            viewSearchResultsSection language model body False

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl language

        Error err ->
            viewSearchResultsErrorTmpl language err

        _ ->
            viewSearchResultsErrorTmpl language "An unknown error occurred."


viewSearchResultsSection : Language -> RecordPageModel RecordMsg -> SearchBody -> Bool -> Element RecordMsg
viewSearchResultsSection language model body isLoading =
    let
        renderedPreview =
            case model.preview of
                Loading resp ->
                    viewPreviewRouter language RecordMsg.UserClickedClosePreviewWindow resp

                Response resp ->
                    viewPreviewRouter language RecordMsg.UserClickedClosePreviewWindow (Just resp)

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
    if body.totalItems == 0 then
        viewSearchResultsNotFound language

    else
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
                , inFront <| viewResultsListLoadingScreenTmpl isLoading
                ]
                [ viewSearchResultsList language model body ]
            ]


viewSearchResultsNotFound : Language -> Element RecordMsg
viewSearchResultsNotFound language =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , padding 20
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ h3 language localTranslations.noResultsHeader ]
            , row
                [ width fill ]
                [ renderParagraph language localTranslations.noResultsBody ]
            ]
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
            viewSourceSearchResult
                { language = language
                , selectedResult = selectedResult
                , body = body
                , clickForPreviewMsg = RecordMsg.UserClickedSearchResultForPreview
                }

        _ ->
            none


viewFacetsForSourcesMode : Language -> RecordPageModel RecordMsg -> SearchBody -> Element RecordMsg
viewFacetsForSourcesMode language model body =
    let
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
                    [ searchKeywordInput
                        { language = language
                        , submitMsg = RecordMsg.UserTriggeredSearchSubmit
                        , changeMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        }
                    ]
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
            , viewFacetSection language
                RecordMsg.NothingHappened
                [ viewFacetToggleSection language activeSearch body ]

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


viewFacetToggleSection : Language -> ActiveSearch RecordMsg -> SearchBody -> Element RecordMsg
viewFacetToggleSection language activeSearch body =
    let
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , body = body
            , selectColumns = 3
            }

        sourceContentsToggle =
            viewFacet (facetConfig "hide-source-contents") facetRecordMsgConfig

        sourceCollectionsToggle =
            viewFacet (facetConfig "hide-source-collections") facetRecordMsgConfig

        compositeVolumesToggle =
            viewFacet (facetConfig "hide-composite-volumes") facetRecordMsgConfig

        hasDigitizationToggle =
            viewFacet (facetConfig "has-digitization") facetRecordMsgConfig

        hasIiifToggle =
            viewFacet (facetConfig "has-iiif") facetRecordMsgConfig

        isArrangementToggle =
            viewFacet (facetConfig "is-arrangement") facetRecordMsgConfig

        hasIncipitsToggle =
            viewFacet (facetConfig "has-incipits") facetRecordMsgConfig

        allToggles =
            [ sourceCollectionsToggle
            , sourceContentsToggle
            , compositeVolumesToggle
            , hasDigitizationToggle
            , hasIiifToggle
            , isArrangementToggle
            , hasIncipitsToggle
            ]

        allAreEmpty =
            List.all (\a -> a == none) allToggles
    in
    if allAreEmpty then
        none

    else
        row
            [ width fill
            , alignTop
            ]
            [ column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ sourceContentsToggle
                , sourceCollectionsToggle
                , compositeVolumesToggle
                ]
            , column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ hasDigitizationToggle
                , hasIiifToggle
                ]
            , column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ isArrangementToggle
                , hasIncipitsToggle
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
            , viewSearchButtons
                { language = language
                , model = model
                , submitMsg = RecordMsg.UserTriggeredSearchSubmit
                , resetMsg = RecordMsg.UserResetAllFilters
                }
            ]
        ]


viewRecordSourceSearchTabBar :
    { language : Language
    , model : RecordPageModel RecordMsg
    , searchUrl : String
    , recordId : String
    }
    -> Element RecordMsg
viewRecordSourceSearchTabBar { language, model, searchUrl, recordId } =
    let
        currentMode =
            model.currentTab

        sourceCount searchData =
            toFloat searchData.totalItems
                |> formatNumberByLanguage language

        localizedSources =
            extractLabelFromLanguageMap language localTranslations.sources

        sourceLabel =
            case model.searchResults of
                Response (SearchData searchData) ->
                    el
                        []
                        (text <| localizedSources ++ " (" ++ sourceCount searchData ++ ")")

                _ ->
                    row
                        [ spacing 5 ]
                        [ text localizedSources
                        , animatedLoader
                            [ width (px 15), height (px 15) ]
                            (spinnerSvg colourScheme.slateGrey)
                        ]

        descriptionTabBorder =
            case currentMode of
                DefaultRecordViewTab _ ->
                    colourScheme.lightBlue |> convertColorToElementColor

                _ ->
                    colourScheme.cream |> convertColorToElementColor

        searchTabBorder =
            case currentMode of
                RelatedSourcesSearchTab _ ->
                    colourScheme.lightBlue |> convertColorToElementColor

                _ ->
                    colourScheme.cream |> convertColorToElementColor
    in
    row
        [ centerX
        , width fill
        , height (px 25)
        , spacing 15
        ]
        [ el
            [ width shrink
            , height fill
            , Font.center
            , alignLeft
            , pointer
            , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
            , Border.color descriptionTabBorder
            ]
            (button
                []
                { onPress = Just <| UserClickedRecordViewTab (DefaultRecordViewTab recordId)
                , label = text <| extractLabelFromLanguageMap language localTranslations.description
                }
            )
        , el
            [ width shrink
            , height fill
            , alignLeft
            , centerY
            , pointer
            , headingSM
            , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
            , Border.color searchTabBorder
            ]
            (button
                []
                { onPress = Just <| UserClickedRecordViewTab (RelatedSourcesSearchTab searchUrl)
                , label = sourceLabel
                }
            )
        ]


viewRecordTopBarDescriptionOnly : Element msg
viewRecordTopBarDescriptionOnly =
    row
        [ centerX
        , width fill
        , height (px 25)
        , spacing 15
        ]
        [ el
            [ width shrink
            , height fill
            , Font.center
            , alignLeft
            , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
            , Border.color (colourScheme.lightBlue |> convertColorToElementColor)
            ]
            (text "Description")
        ]
