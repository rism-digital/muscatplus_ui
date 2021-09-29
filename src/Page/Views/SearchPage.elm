module Page.Views.SearchPage exposing (..)

import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, fillPortion, height, htmlAttribute, inFront, maximum, minimum, none, padding, paddingXY, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Model exposing (Response(..))
import Page.Query exposing (Filter(..), QueryArgs)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (ModeFacet, SearchBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (headerBottomBorder, minimalDropShadow, searchColumnVerticalSize)
import Page.UI.Components exposing (dropdownSelect, searchKeywordInput)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Pagination exposing (viewPagination)
import Page.Views.SearchPage.Facets exposing (viewFacet, viewModeItems)
import Page.Views.SearchPage.Loading exposing (searchModeSelectorLoading, viewSearchResultsLoading)
import Page.Views.SearchPage.Previews exposing (viewPreviewLoading, viewPreviewRouter)
import Page.Views.SearchPage.Results exposing (viewSearchResult)
import Search exposing (ActiveSearch)
import Search.ActiveFacet exposing (ActiveFacet(..))


view : Model -> Element Msg
view model =
    row
        [ width fill
        , height fill
        , centerX
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewTopBar model
            , viewSearchBody model
            ]
        ]


viewSearchBody : Model -> Element Msg
viewSearchBody model =
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
            [ searchResultsViewRouter model ]
        ]


viewTopBar : Model -> Element Msg
viewTopBar model =
    let
        msgs =
            { submitMsg = Msg.UserTriggeredSearchSubmit
            , changeMsg = Msg.UserInputTextInQueryBox
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
                    [ searchKeywordInput msgs qText model.language ]
                ]
            , searchModeSelectorRouter model
            ]
        ]


searchModeSelectorRouter : Model -> Element Msg
searchModeSelectorRouter model =
    let
        activeSearch =
            model.activeSearch

        selectedMode =
            activeSearch.selectedMode

        page =
            model.page

        response =
            page.response

        modeView =
            case response of
                Response (SearchData data) ->
                    searchModeSelectorView model data.modes

                _ ->
                    searchModeSelectorLoading
    in
    modeView


searchModeSelectorView : Model -> Maybe ModeFacet -> Element Msg
searchModeSelectorView model modeFacet =
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
            [ viewMaybe (viewModeItems currentMode model.language) modeFacet
            ]
        ]


searchResultsViewRouter : Model -> Element Msg
searchResultsViewRouter model =
    let
        page =
            model.page

        resp =
            page.response

        sectionView =
            case resp of
                Loading ->
                    viewSearchResultsLoading model

                Response (SearchData body) ->
                    viewSearchResultsSection model body

                Error _ ->
                    viewSearchResultsError model

                NoResponseToShow ->
                    -- In case we're just booting the app up, show
                    -- the loading message.
                    viewSearchResultsLoading model

                _ ->
                    -- For any other responses, show the error.
                    viewSearchResultsError model
    in
    sectionView


viewSearchResultsSection : Model -> SearchBody -> Element Msg
viewSearchResultsSection model body =
    let
        language =
            model.language

        searchParams =
            model.activeSearch
    in
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
            [ viewSearchResultsListPanel language searchParams body
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
            [ viewSearchResultsControlPanel model
            ]
        ]


viewSearchResultsListPanel : Language -> ActiveSearch -> SearchBody -> Element Msg
viewSearchResultsListPanel language searchParams body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewSearchResultsList language searchParams body
            , viewPagination language body.pagination UserClickedSearchResultsPagination
            ]
        ]


viewSearchResultsList : Language -> ActiveSearch -> SearchBody -> Element Msg
viewSearchResultsList language searchParams body =
    let
        selectedResult =
            searchParams.selectedResult
    in
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
            (List.map (\result -> viewSearchResult language selectedResult result) body.items)
        ]


viewSearchResultsControlPanel : Model -> Element Msg
viewSearchResultsControlPanel model =
    let
        searchParams =
            model.activeSearch

        language =
            model.language

        preview =
            searchParams.preview

        renderedPreview =
            case preview of
                Loading ->
                    -- TODO: Make a preview loading view
                    viewPreviewLoading

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
            [ viewSearchControlSection model ]
        ]


viewSearchPageSort : Model -> Element Msg
viewSearchPageSort model =
    let
        page =
            model.page

        language =
            model.language

        activeSearch =
            model.activeSearch

        selectorView =
            case page.response of
                Response (SearchData data) ->
                    let
                        pagination =
                            data.pagination

                        thisPage =
                            formatNumberByLanguage (toFloat pagination.thisPage) language

                        totalPages =
                            formatNumberByLanguage (toFloat pagination.totalPages) language

                        pageLabel =
                            extractLabelFromLanguageMap language localTranslations.page

                        pageInfo =
                            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages

                        sorting =
                            data.sorts

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
                                            (\inp -> UserChangedResultSorting inp)
                                            listOfLabelsForResultSort
                                            (\inp -> inp)
                                            chosenSort
                                        )
                                    ]
                                ]
                            ]
                        ]

                _ ->
                    none
    in
    selectorView


viewSearchResultsError : Model -> Element Msg
viewSearchResultsError model =
    let
        page =
            model.page

        errorMessage =
            case page.response of
                Error msg ->
                    text msg

                _ ->
                    none
    in
    errorMessage


viewSearchControlSection : Model -> Element Msg
viewSearchControlSection model =
    let
        page =
            model.page

        resp =
            page.response

        language =
            model.language

        activeSearch =
            model.activeSearch

        controlView =
            case resp of
                Response (SearchData body) ->
                    viewSearchControls language activeSearch body

                _ ->
                    none

        activeFilters =
            case resp of
                Response (SearchData body) ->
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
                    , viewSearchPageSort model
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


viewSearchControls : Language -> ActiveSearch -> SearchBody -> Element Msg
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


viewActiveFilters : Language -> ActiveSearch -> Element Msg
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


viewActiveSearchQuery : Language -> String -> Element Msg
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
                , onClick UserClickedClearSearchQueryBox
                ]
                (closeWindowSvg colourScheme.white)
            ]
        ]


viewActiveFilter : Language -> ActiveFacet -> Element Msg
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
                , onClick (UserClickedRemoveActiveFilter facetAlias facetValue)
                ]
                (closeWindowSvg colourScheme.white)
            ]
        ]


viewFacetsForIncipitsMode : Language -> ActiveSearch -> SearchBody -> Element Msg
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
                    [ viewFacet "notation" language activeSearch body ]
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
                    ]
                , column
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ viewFacet "date-range" language activeSearch body ]
                ]
            ]
        ]


viewFacetsForSourcesMode : Language -> ActiveSearch -> SearchBody -> Element Msg
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
            ]
        ]


viewFacetsForPeopleMode : Language -> ActiveSearch -> SearchBody -> Element Msg
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


viewFacetsForInstitutionsMode : Language -> ActiveSearch -> SearchBody -> Element Msg
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
