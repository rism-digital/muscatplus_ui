module Page.Search.Views exposing (..)

import ActiveSearch.ActiveFacet exposing (ActiveFacet(..))
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, fillPortion, height, htmlAttribute, inFront, maximum, minimum, none, padding, paddingXY, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (ModeFacet, SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet, viewModeItems)
import Page.Search.Views.Loading exposing (searchModeSelectorLoading, viewSearchResultsLoading)
import Page.Search.Views.Previews exposing (viewPreviewLoading, viewPreviewRouter)
import Page.Search.Views.Results exposing (viewSearchResult)
import Page.UI.Attributes exposing (headerBottomBorder, minimalDropShadow, searchColumnVerticalSize)
import Page.UI.Components exposing (dropdownSelect, searchKeywordInput)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Pagination exposing (viewPagination)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> SearchPageModel -> Element SearchMsg
view session model =
    row
        [ width fill
        , height fill
        , centerX
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewTopBar session.language model
            , viewSearchBody session.language model
            ]
        ]


viewSearchBody : Language -> SearchPageModel -> Element SearchMsg
viewSearchBody language model =
    row
        [ width fill
        , height fill
        , clipY
        ]
        [ column
            [ alignTop
            , width fill
            , height fill
            ]
            [ searchResultsViewRouter language model ]
        ]


viewTopBar : Language -> SearchPageModel -> Element SearchMsg
viewTopBar lang model =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserInputTextInQueryBox
            }

        activeSearch =
            model.activeSearch

        activeQuery =
            activeSearch.query

        qText =
            Maybe.withDefault "" activeQuery.query
    in
    row
        [ width fill
        , height (px searchHeaderHeight)
        , Border.widthEach { top = 0, left = 0, bottom = 2, right = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , minimalDropShadow
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ column
                    [ width (fill |> minimum 800 |> maximum 1100)
                    , alignTop
                    , paddingXY 20 10
                    ]
                    [ searchKeywordInput lang msgs qText ]
                ]
            , searchModeSelectorRouter lang model
            ]
        ]


searchModeSelectorRouter : Language -> SearchPageModel -> Element SearchMsg
searchModeSelectorRouter language model =
    let
        response =
            model.response

        modeView =
            case response of
                Response (SearchData data) ->
                    searchModeSelectorView language model data.modes

                Loading (Just (SearchData oldData)) ->
                    searchModeSelectorView language model oldData.modes

                _ ->
                    searchModeSelectorLoading
    in
    modeView


searchModeSelectorView : Language -> SearchPageModel -> Maybe ModeFacet -> Element SearchMsg
searchModeSelectorView lang model modeFacet =
    let
        activeSearch =
            model.activeSearch

        currentMode =
            activeSearch.selectedMode
    in
    row
        [ width fill ]
        [ column
            [ width fill
            ]
            [ viewMaybe (viewModeItems currentMode lang) modeFacet
            ]
        ]


searchResultsViewRouter : Language -> SearchPageModel -> Element SearchMsg
searchResultsViewRouter language model =
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection language model oldData

        Loading _ ->
            viewSearchResultsLoading language model

        Response (SearchData body) ->
            viewSearchResultsSection language model body

        Error _ ->
            viewSearchResultsError language model

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoading language model

        _ ->
            -- For any other responses, show the error.
            viewSearchResultsError language model


viewSearchResultsSection : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewSearchResultsSection language model body =
    row
        [ width fill
        ]
        [ column
            [ width (fill |> minimum 600 |> maximum 1100)
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            , htmlAttribute (HA.id "search-results-list")
            ]
            [ viewSearchResultsListPanel language model body
            ]
        , column
            [ Border.widthEach { top = 0, left = 2, right = 0, bottom = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            , Background.color (colourScheme.cream |> convertColorToElementColor)
            , width (fill |> minimum 800)
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsControlPanel language model
            ]
        ]


viewSearchResultsListPanel : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewSearchResultsListPanel language model body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewSearchResultsList language model body
            , viewPagination language body.pagination SearchMsg.UserClickedSearchResultsPagination
            ]
        ]


viewSearchResultsList : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewSearchResultsList language model body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 20
            ]
            (List.map (\result -> viewSearchResult language model.selectedResult result) body.items)
        ]


viewSearchResultsControlPanel : Language -> SearchPageModel -> Element SearchMsg
viewSearchResultsControlPanel language model =
    let
        preview =
            model.preview

        renderedPreview =
            case preview of
                Loading Nothing ->
                    -- TODO: Make a preview loading view
                    viewPreviewLoading

                Loading (Just oldData) ->
                    viewPreviewRouter language oldData

                Response resp ->
                    viewPreviewRouter language resp

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
            , inFront renderedPreview
            ]
            [ viewSearchControlSection language model ]
        ]


viewSearchPageSort : Language -> SearchPageModel -> Element SearchMsg
viewSearchPageSort language model =
    let
        activeSearch =
            model.activeSearch
    in
    case model.response of
        Response (SearchData body) ->
            viewPaginationSortSelector language activeSearch body

        Loading (Just (SearchData body)) ->
            viewPaginationSortSelector language activeSearch body

        _ ->
            none


viewPaginationSortSelector : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewPaginationSortSelector language activeSearch body =
    let
        pagination =
            body.pagination

        thisPage =
            formatNumberByLanguage (toFloat pagination.thisPage) language

        totalPages =
            formatNumberByLanguage (toFloat pagination.totalPages) language

        pageLabel =
            extractLabelFromLanguageMap language localTranslations.page

        pageInfo =
            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages

        sorting =
            body.sorts

        listOfLabelsForResultSort =
            List.map
                (\d -> ( d.alias, extractLabelFromLanguageMap language d.label ))
                sorting

        chosenSort =
            Maybe.withDefault "relevance" activeSearch.selectedResultSort
    in
    row
        [ width fill ]
        [ column
            [ width (fillPortion 2) ]
            [ text pageInfo ]
        , column
            [ width (fillPortion 3) ]
            [ row
                [ width fill
                , spacing 10
                ]
                [ column
                    [ width shrink ]
                    [ text "Sort by" ]
                , column
                    [ width fill ]
                    [ el
                        []
                        (dropdownSelect
                            (\inp -> SearchMsg.UserChangedResultSorting inp)
                            listOfLabelsForResultSort
                            (\inp -> inp)
                            chosenSort
                        )
                    ]
                ]
            ]
        ]


viewSearchResultsError : Language -> SearchPageModel -> Element msg
viewSearchResultsError language model =
    case model.response of
        Error msg ->
            text msg

        _ ->
            none


viewSearchControlSection : Language -> SearchPageModel -> Element SearchMsg
viewSearchControlSection language model =
    let
        resp =
            model.response

        activeSearch =
            model.activeSearch

        controlView =
            case resp of
                Response (SearchData body) ->
                    viewSearchControls language activeSearch body

                Loading (Just (SearchData body)) ->
                    viewSearchControls language activeSearch body

                _ ->
                    none

        activeFilters =
            case resp of
                Response (SearchData _) ->
                    viewActiveFilters language activeSearch

                Loading (Just (SearchData _)) ->
                    viewActiveFilters language activeSearch

                _ ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            ]
            [ row
                [ width fill
                , headerBottomBorder
                , paddingXY 0 10
                ]
                [ column
                    [ width fill
                    , alignTop
                    , spacing 20
                    ]
                    [ row
                        [ width fill ]
                        [ el
                            [ Font.size 16
                            , Font.semiBold
                            , alignTop
                            ]
                            (text "Active search parameters")
                        ]
                    , viewSearchPageSort language model
                    , activeFilters
                    ]
                ]
            , row
                [ width fill
                ]
                [ column
                    [ width fill
                    , height fill
                    , spacing 20
                    , alignTop
                    ]
                    [ row
                        [ width fill ]
                        [ el
                            [ Font.size 16
                            , Font.semiBold
                            , alignTop
                            ]
                            (text "Search controls")
                        ]
                    , controlView
                    ]
                ]
            ]
        ]


viewSearchControls : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewSearchControls language activeSearch body =
    let
        facetLayout =
            case activeSearch.selectedMode of
                IncipitsMode ->
                    viewFacetsForIncipitsMode language activeSearch body

                SourcesMode ->
                    viewFacetsForSourcesMode language activeSearch body

                PeopleMode ->
                    viewFacetsForPeopleMode language activeSearch body

                InstitutionsMode ->
                    viewFacetsForInstitutionsMode language activeSearch body

                LiturgicalFestivalsMode ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            ]
            [ facetLayout
            ]
        ]


viewActiveFilters : Language -> ActiveSearch -> Element SearchMsg
viewActiveFilters language activeSearch =
    let
        activeFacets =
            activeSearch.activeFacets

        activeQuery =
            activeSearch.query

        activeFacetControls =
            List.map (viewActiveFilter language) activeFacets

        activeControls =
            case activeQuery.query of
                Just q ->
                    viewActiveSearchQuery language q :: activeFacetControls

                Nothing ->
                    activeFacetControls
    in
    row
        []
        [ column
            [ spacing 10 ]
            activeControls
        ]


viewActiveSearchQuery : Language -> String -> Element SearchMsg
viewActiveSearchQuery language query =
    row
        [ width shrink
        , Background.color (colourScheme.red |> convertColorToElementColor)
        , Border.rounded 5
        , padding 5
        , spacing 5
        , Font.semiBold
        , Font.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ width (fillPortion 3) ]
            [ el
                []
                (text ("Query: " ++ query))
            ]
        , column
            [ width (fillPortion 1)
            ]
            [ el
                [ width (px 20)
                , onClick SearchMsg.UserClickedClearSearchQueryBox
                ]
                (closeWindowSvg colourScheme.white)
            ]
        ]


viewActiveFilter : Language -> ActiveFacet -> Element SearchMsg
viewActiveFilter language (ActiveFacet facetType facetLabel facetAlias facetValue friendlyValue) =
    let
        label =
            extractLabelFromLanguageMap language facetLabel

        value =
            case friendlyValue of
                Just v ->
                    extractLabelFromLanguageMap language v

                Nothing ->
                    facetValue
    in
    row
        [ width shrink
        , Background.color (colourScheme.red |> convertColorToElementColor)
        , Border.rounded 5
        , padding 5
        , spacing 5
        , Font.semiBold
        , Font.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ width (fillPortion 3) ]
            [ el
                []
                (text (label ++ ": " ++ value))
            ]
        , column
            [ width (fillPortion 1)
            ]
            [ el
                [ width (px 20)
                , onClick (SearchMsg.UserClickedRemoveActiveFilter facetAlias facetValue)
                ]
                (closeWindowSvg colourScheme.white)
            ]
        ]


viewFacetsForIncipitsMode : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewFacetsForIncipitsMode language activeSearch body =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 15
            ]
            [ row
                [ width fill ]
                [ column [ width fill ]
                    [ viewFacet "notation" language activeSearch body
                    ]
                ]
            , row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing 10
                    ]
                    [ viewFacet "is-mensural" language activeSearch body
                    , viewFacet "has-notation" language activeSearch body
                    ]
                ]
            , row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ viewFacet "composer" language activeSearch body
                    , viewFacet "clef" language activeSearch body
                    ]
                , column
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ viewFacet "date-range" language activeSearch body
                    ]
                ]
            ]
        ]


viewFacetsForSourcesMode : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewFacetsForSourcesMode language activeSearch body =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 15
            ]
            [ viewFacet "hide-source-contents" language activeSearch body
            , viewFacet "hide-source-collections" language activeSearch body
            , viewFacet "hide-composite-volumes" language activeSearch body
            , viewFacet "has-incipits" language activeSearch body
            , viewFacet "has-digitization" language activeSearch body
            , viewFacet "date-range" language activeSearch body
            , viewFacet "num-holdings" language activeSearch body
            , viewFacet "holding-institution" language activeSearch body
            , viewFacet "source-type" language activeSearch body
            , viewFacet "content-types" language activeSearch body
            , viewFacet "material-group-types" language activeSearch body
            , viewFacet "subjects" language activeSearch body
            , viewFacet "text-language" language activeSearch body
            , viewFacet "format-extent" language activeSearch body
            ]
        ]


viewFacetsForPeopleMode : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewFacetsForPeopleMode language activeSearch body =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 15
            ]
            [ viewFacet "person-role" language activeSearch body
            , viewFacet "date-range" language activeSearch body
            ]
        ]


viewFacetsForInstitutionsMode : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewFacetsForInstitutionsMode language activeSearch body =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 15
            ]
            [ viewFacet "date-range" language activeSearch body
            , viewFacet "city" language activeSearch body
            ]
        ]
