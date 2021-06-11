module Page.Views.SearchPage exposing (..)

import Element exposing (Element, alignLeft, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, link, maximum, minimum, none, padding, paddingEach, paddingXY, pointer, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Model exposing (Response(..))
import Page.RecordTypes exposing (RecordType(..))
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.RecordTypes.Search exposing (Facet, SearchBody, SearchResult)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (bodyRegular, bodySM, minimalDropShadow, searchColumnVerticalSize)
import Page.UI.Components exposing (h5, searchKeywordInput)
import Page.UI.Images exposing (bookOpenSvg, digitizedImagesSvg, musicNotationSvg, sourceSvg)
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
            { submitMsg = Msg.UserClickedSearchSubmitButton
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
                    [ text "Hide item records"
                    ]
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
                    viewSearchResultsSection language activeSearch body

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


viewSearchResultsSection : Language -> ActiveSearch -> SearchBody -> Element Msg
viewSearchResultsSection language searchParams body =
    row
        [ width fill
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , Background.color colourScheme.white
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsListSection language body
            ]
        , column
            [ Border.widthEach { top = 0, left = 2, right = 0, bottom = 0 }
            , Border.color colourScheme.slateGrey

            --, Background.color colourScheme.white
            , width (fill |> minimum 800)
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsPreviewSection searchParams language
            ]
        ]


viewSearchResultsListSection : Language -> SearchBody -> Element Msg
viewSearchResultsListSection language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewSearchResultsList language body
            , viewSearchResultsPagination language body.pagination
            ]
        ]


viewSearchResultsList : Language -> SearchBody -> Element Msg
viewSearchResultsList language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 60
            , htmlAttribute (HA.id "search-results-list")
            ]
            (List.map (\result -> viewSearchResult language result) body.items)
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
                    viewPreviewRouter language resp

                Error _ ->
                    el [] (text "Error")

                NoResponseToShow ->
                    el [] (text "Nothing to see here")
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ renderedPreview ]
        ]


makeFlagIcon : Element msg -> String -> Element msg
makeFlagIcon iconImage iconLabel =
    column
        [ bodySM
        , padding 4
        , Border.width 1
        , Border.color colourScheme.darkGrey
        , Border.rounded 4
        ]
        [ row
            [ spacing 5
            ]
            [ el
                [ width (px 20)
                , height (px 20)
                ]
                iconImage
            , text iconLabel
            ]
        ]


viewSearchResult : Language -> SearchResult -> Element Msg
viewSearchResult language result =
    let
        resultTitle =
            el
                [ Font.color colourScheme.lightBlue
                , width fill
                , onClick (UserClickedSearchResultForPreview result.id)
                , pointer
                ]
                (h5 language result.label)

        flags =
            result.flags

        digitizedImagesFlag =
            flags.hasDigitization

        isItemFlag =
            flags.isItemRecord

        hasIncipits =
            flags.hasIncipits

        isFullSource =
            result.type_ == Source && flags.isItemRecord == False

        fullSourceIcon =
            if isFullSource == True then
                makeFlagIcon sourceSvg "Source record"

            else
                none

        digitalImagesIcon =
            if digitizedImagesFlag == True then
                makeFlagIcon digitizedImagesSvg "Digitization available"

            else
                none

        isItemIcon =
            if isItemFlag == True then
                makeFlagIcon bookOpenSvg "Item record"

            else
                none

        incipitIcon =
            if hasIncipits == True then
                makeFlagIcon musicNotationSvg "Has incipits"

            else
                none

        partOf =
            case result.partOf of
                Just partOfBody ->
                    let
                        source =
                            partOfBody.source
                    in
                    row
                        [ width fill
                        , bodyRegular
                        ]
                        [ column
                            [ width fill
                            ]
                            [ row
                                [ width fill ]
                                [ text "Part of " -- TODO: Translate!
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
                        [ width fill
                        , bodyRegular
                        ]
                        [ column
                            [ width fill
                            ]
                            (List.map (\l -> el [] (text (extractLabelFromLanguageMap language l.value))) fields)
                        ]

                Nothing ->
                    none
    in
    row
        [ width fill

        --, height (px 100)
        , alignTop

        --, Border.widthEach { left = 2, right = 0, bottom = 0, top = 0 }
        --, Border.color colourScheme.midGrey
        , paddingXY 10 0
        ]
        [ column
            [ width fill
            , spacing 10
            , alignTop
            ]
            [ row
                [ width fill
                , alignLeft
                , spacing 10
                ]
                [ resultTitle
                ]
            , partOf
            , summary
            , row
                [ width fill
                , alignLeft
                , spacing 8
                , paddingEach { top = 8, bottom = 0, left = 0, right = 0 }
                ]
                [ digitalImagesIcon
                , fullSourceIcon
                , isItemIcon
                , incipitIcon
                ]
            ]
        ]


viewSearchResultsLoading : Model -> Element Msg
viewSearchResultsLoading model =
    text "Loading"


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
