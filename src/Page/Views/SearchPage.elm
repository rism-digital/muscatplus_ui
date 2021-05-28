module Page.Views.SearchPage exposing (view)

import Element exposing (Element, alignBottom, alignTop, centerX, clipY, column, el, fill, height, link, maximum, minimum, none, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Model exposing (Response(..))
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.RecordTypes.Search exposing (Facet, SearchBody, SearchPagination, SearchResult)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (minimalDropShadow, searchColumnVerticalSize)
import Page.UI.Components exposing (h4, h5, searchKeywordInput)
import Page.UI.Style exposing (colourScheme, searchHeaderHeight)
import Page.Views.SearchPage.Facets exposing (viewModeItems)
import Page.Views.SearchPage.Pagination exposing (viewSearchResultsPagination)
import Page.Views.SearchPage.Previews exposing (viewPreviewRouter)
import Search exposing (ActiveSearch)


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
            { submitMsg = Msg.SearchSubmit
            , changeMsg = Msg.SearchInput
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
        , Border.color colourScheme.slateGrey
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
                , column
                    [ width fill ]
                    []
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
                    searchModeSelectorView selectedMode data.modes model.language

                _ ->
                    searchModeSelectorLoading
    in
    modeView


searchModeSelectorView : ResultMode -> Facet -> Language -> Element Msg
searchModeSelectorView currentMode modeFacet language =
    row
        [ width fill ]
        [ column
            [ width fill
            ]
            [ viewModeItems currentMode modeFacet language
            ]
        ]


searchModeSelectorLoading : Element Msg
searchModeSelectorLoading =
    none


searchResultsViewRouter : Model -> Element Msg
searchResultsViewRouter model =
    let
        page =
            model.page

        resp =
            page.response

        language =
            model.language

        activeSearch =
            model.activeSearch

        sectionView =
            case resp of
                Loading ->
                    viewSearchResultsLoading model

                Response (SearchData body) ->
                    viewSearchResultsSection body activeSearch language

                Error e ->
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


viewSearchResultsSection : SearchBody -> ActiveSearch -> Language -> Element Msg
viewSearchResultsSection body searchParams language =
    row
        [ width fill
        ]
        [ column
            [ width (fill |> minimum 600 |> maximum 800)
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsListSection body language
            ]
        , column
            [ Border.widthEach { top = 0, left = 2, right = 0, bottom = 0 }
            , Border.color colourScheme.slateGrey
            , Background.color colourScheme.white
            , width fill
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsPreviewSection searchParams language
            ]
        ]


viewSearchResultsListSection : SearchBody -> Language -> Element Msg
viewSearchResultsListSection body language =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewSearchResultsList body language
            , viewSearchResultsPagination body.pagination language
            ]
        ]


viewSearchResultsList : SearchBody -> Language -> Element Msg
viewSearchResultsList body language =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            (List.map (\i -> viewSearchResult i language) body.items)
        ]


viewSearchResultsPreviewSection : ActiveSearch -> Language -> Element Msg
viewSearchResultsPreviewSection searchParams language =
    let
        preview =
            searchParams.preview

        renderedPreview =
            case preview of
                Loading ->
                    el [] (text "Loading")

                Response resp ->
                    viewPreviewRouter resp language

                Error _ ->
                    el [] (text "Error")

                NoResponseToShow ->
                    el [] (text "Nothing to see here")
    in
    row
        [ width fill
        , height (px 2000)
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ renderedPreview ]
        ]


viewSearchResult : SearchResult -> Language -> Element Msg
viewSearchResult result language =
    let
        resultTitle =
            el
                [ Font.color colourScheme.lightBlue
                , width fill
                , onClick (PreviewSearchResult result.id)
                , pointer
                ]
                (h5 language result.label)

        partOf =
            case result.partOf of
                Just source ->
                    row
                        [ width fill ]
                        [ column
                            [ width fill ]
                            [ row
                                [ width fill ]
                                [ text "Part of "
                                , link
                                    [ Font.color colourScheme.lightBlue ]
                                    { url = source.id, label = text (extractLabelFromLanguageMap language source.label) }
                                ]
                            ]
                        ]

                Nothing ->
                    none

        summary =
            case result.summary of
                Just fields ->
                    row
                        [ width fill ]
                        (List.map (\l -> el [] (text (extractLabelFromLanguageMap language l.value))) fields)

                Nothing ->
                    none
    in
    row
        [ width fill
        , height (px 60)
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ resultTitle ]
            , partOf
            , summary
            ]
        ]


viewSearchResultsLoading : Model -> Element Msg
viewSearchResultsLoading model =
    text "Loading"


viewSearchResultsError : Model -> Element Msg
viewSearchResultsError model =
    text "Error"
