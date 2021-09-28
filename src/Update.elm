module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Dict
import Http exposing (Error(..))
import Language exposing (parseLocaleToLanguage)
import List.Extra as LE
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Converters exposing (convertFacetToFilter, convertFacetToResultMode, convertRangeFacetToRangeSlider, filterMap)
import Page.Decoders exposing (recordResponseDecoder)
import Page.Model exposing (CurrentRecordViewTab(..), Response(..))
import Page.Query exposing (FacetBehaviour(..), Filter(..), buildQueryParameters)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (FacetData(..), FacetItem(..))
import Page.Response exposing (ServerData(..))
import Page.Response.DataResponse
import Page.Response.PageSearchResponse
import Page.Response.PreviewResponse
import Page.Route exposing (Route(..), parseUrl)
import Page.UI.Facets.RangeSlider as RangeSlider exposing (RangeSlider)
import Page.UI.Keyboard as Keyboard exposing (buildNotationRequestQuery)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Ports.LocalStorage exposing (saveLanguagePreference)
import Request exposing (createRequest, serverUrl)
import Search
import Search.ActiveFacet exposing (convertFilterToActiveFacet)
import Search.Update as Search
import Url
import Url.Builder
import Viewport exposing (jumpToId, resetViewport, resetViewportOf)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.ServerRespondedWithData (Ok ( metadata, response )) ->
            Page.Response.DataResponse.serverRespondedWithData model response

        Msg.ServerRespondedWithData (Err error) ->
            Page.Response.DataResponse.serverRespondedWithDataError model error

        Msg.ServerRespondedWithPreview (Ok ( metadata, response )) ->
            Page.Response.PreviewResponse.serverRespondedWithPreview model response

        Msg.ServerRespondedWithPreview (Err error) ->
            Page.Response.PreviewResponse.serverRespondedWithPreviewError model error

        Msg.ServerRespondedWithPageSearch (Ok ( metadata, response )) ->
            Page.Response.PageSearchResponse.serverRespondedWithPageSearch model response

        Msg.ServerRespondedWithPageSearch (Err error) ->
            Page.Response.PageSearchResponse.serverRespondedWithPageSearchError model error

        Msg.ClientChangedUrl url ->
            let
                oldPage =
                    model.page

                newRoute =
                    parseUrl url

                activeSearch =
                    case newRoute of
                        FrontPageRoute ->
                            Search.init newRoute

                        _ ->
                            model.activeSearch

                newPage =
                    { oldPage
                        | route = newRoute
                        , currentTab = DefaultRecordViewTab
                        , searchResults = NoResponseToShow
                    }

                newQuery =
                    case newRoute of
                        SearchPageRoute qargs nargs ->
                            List.append (buildQueryParameters qargs) (buildNotationQueryParameters nargs)

                        _ ->
                            []

                newUrl =
                    serverUrl [ url.path ] newQuery
            in
            ( { model
                | page = newPage
                , activeSearch = activeSearch
              }
            , Cmd.batch
                [ createRequest Msg.ServerRespondedWithData recordResponseDecoder newUrl
                ]
            )

        Msg.UserResizedWindow device ->
            ( { model | device = device }, Cmd.none )

        Msg.UserRequestedUrlChange urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        Msg.UserChangedLanguageSelect lang ->
            ( { model | language = parseLocaleToLanguage lang }
            , saveLanguagePreference lang
            )

        Msg.UserChangedResultSorting sort ->
            let
                oldSearch =
                    model.activeSearch

                oldQuery =
                    oldSearch.query

                -- even though this is a 'Maybe' value, if the user goes through
                -- the trouble of selecting a new sort then we explicitly use that.
                sortValue =
                    Just sort

                newQuery =
                    { oldQuery | sort = sortValue }

                newSearch =
                    { oldSearch
                        | selectedResultSort = sortValue
                        , query = newQuery
                    }

                newModel =
                    { model | activeSearch = newSearch }
            in
            Search.searchSubmit newModel

        Msg.UserTriggeredSearchSubmit ->
            Search.searchSubmit model

        Msg.UserInputTextInQueryBox qtext ->
            let
                oldSearch =
                    model.activeSearch

                oldQueryParams =
                    oldSearch.query

                newQuery =
                    if String.isEmpty qtext then
                        Nothing

                    else
                        Just qtext

                newQueryParams =
                    { oldQueryParams | query = newQuery }

                newSearch =
                    { oldSearch | query = newQueryParams }
            in
            ( { model | activeSearch = newSearch }, Cmd.none )

        Msg.UserClickedModeItem _ itm _ ->
            let
                facetConvertedToResultMode =
                    convertFacetToResultMode itm

                oldSearch =
                    model.activeSearch

                oldQuery =
                    oldSearch.query

                newQuery =
                    { oldQuery | mode = facetConvertedToResultMode }

                newSearch =
                    { oldSearch
                        | query = newQuery
                        , selectedMode = facetConvertedToResultMode
                        , selectedResult = Nothing
                    }

                newModel =
                    { model | activeSearch = newSearch }
            in
            Search.searchSubmit newModel

        Msg.UserClickedFacetToggle label ->
            let
                activeSearch =
                    model.activeSearch

                query =
                    activeSearch.query

                activeFilters =
                    query.filters

                filter =
                    Filter label "true"

                newFilters =
                    if List.member filter activeFilters == True then
                        LE.remove filter activeFilters

                    else
                        filter :: activeFilters

                newQuery =
                    { query | filters = newFilters }

                newSearch =
                    { activeSearch | query = newQuery }

                newModel =
                    { model | activeSearch = newSearch }
            in
            Search.searchSubmit newModel

        Msg.UserClickedFacetExpand alias ->
            let
                activeSearch =
                    model.activeSearch

                expandedFacets =
                    activeSearch.expandedFacets

                isInExpandedList =
                    List.member alias expandedFacets

                newExpandedList =
                    if isInExpandedList then
                        LE.remove alias expandedFacets

                    else
                        alias :: expandedFacets

                newSearch =
                    { activeSearch | expandedFacets = newExpandedList }
            in
            ( { model | activeSearch = newSearch }, Cmd.none )

        Msg.UserClickedFacetItem alias facetItem isChecked ->
            let
                (FacetItem value label count) =
                    facetItem

                activeSearch =
                    model.activeSearch

                query =
                    activeSearch.query

                activeFilters =
                    query.filters

                asFilter =
                    convertFacetToFilter alias facetItem

                newSelected =
                    if List.member asFilter activeFilters then
                        LE.remove asFilter activeFilters

                    else
                        asFilter :: activeFilters

                newQuery =
                    { query | filters = newSelected }

                newSearch =
                    { activeSearch | query = newQuery }

                newModel =
                    { model | activeSearch = newSearch }
            in
            Search.searchSubmit newModel

        Msg.UserChangedFacetBehaviour behaviour ->
            let
                oldSearch =
                    model.activeSearch

                oldQuery =
                    oldSearch.query

                oldBehaviours =
                    oldQuery.facetBehaviours

                fieldAlias =
                    case behaviour of
                        IntersectionBehaviour f ->
                            f

                        UnionBehaviour f ->
                            f

                -- filter the alias from the list of old behaviours, and then
                -- add the new behaviour.
                newBehaviours =
                    List.filter
                        (\b ->
                            let
                                aField =
                                    case b of
                                        IntersectionBehaviour alias ->
                                            alias

                                        UnionBehaviour alias ->
                                            alias
                            in
                            aField /= fieldAlias
                        )
                        oldBehaviours
                        |> (::) behaviour

                newQuery =
                    { oldQuery | facetBehaviours = newBehaviours }

                newSearch =
                    { oldSearch | query = newQuery }

                newModel =
                    { model | activeSearch = newSearch }
            in
            Search.searchSubmit newModel

        Msg.UserInteractedWithPianoKeyboard subMsg ->
            let
                activeSearch =
                    model.activeSearch

                oldKeyboard =
                    activeSearch.keyboard

                ( keyboardModel, keyboardCmd ) =
                    Keyboard.update subMsg oldKeyboard

                newSearch =
                    { activeSearch | keyboard = keyboardModel }

                newModel =
                    { model | activeSearch = newSearch }
            in
            ( newModel
            , Cmd.map Msg.UserInteractedWithPianoKeyboard keyboardCmd
            )

        Msg.UserClickedPianoKeyboardSearchSubmitButton ->
            Search.searchSubmit model

        Msg.UserMovedRangeSlider sliderAlias sliderMsg ->
            let
                fireUpdate =
                    case sliderMsg of
                        RangeSlider.DragEnd _ ->
                            True

                        _ ->
                            False

                oldSearch =
                    model.activeSearch

                query =
                    oldSearch.query

                oldFilters =
                    query.filters

                oldSliders =
                    oldSearch.sliders

                newSlider : Maybe RangeSlider
                newSlider =
                    Dict.get sliderAlias oldSliders
                        |> Maybe.map (RangeSlider.update sliderMsg)

                newSliders =
                    case newSlider of
                        Just sl ->
                            Dict.insert sliderAlias sl oldSliders

                        Nothing ->
                            oldSliders

                newFilter : Maybe Filter
                newFilter =
                    case newSlider of
                        Just sl ->
                            let
                                ( from, to ) =
                                    RangeSlider.getValues sl

                                filterValue =
                                    "[" ++ String.fromFloat from ++ " TO " ++ String.fromFloat to ++ "]"

                                thisFilt =
                                    if fireUpdate == True then
                                        Just (Filter sliderAlias filterValue)

                                    else
                                        Nothing
                            in
                            thisFilt

                        Nothing ->
                            Nothing

                -- remove any old occurrences of the filter
                filteredFilters =
                    if fireUpdate == True then
                        List.filter (\(Filter l _) -> l /= sliderAlias) oldFilters

                    else
                        oldFilters

                newFilters =
                    case newFilter of
                        Just f ->
                            f :: filteredFilters

                        Nothing ->
                            filteredFilters

                newQuery =
                    { query | filters = newFilters }

                newSearch =
                    { oldSearch | sliders = newSliders, query = newQuery }

                newModel =
                    { model | activeSearch = newSearch }

                url =
                    serverUrl [ "search" ] (buildQueryParameters newSearch.query)

                cmd =
                    if fireUpdate == True then
                        Nav.pushUrl model.key url

                    else
                        Cmd.none
            in
            ( newModel, cmd )

        Msg.UserClickedToCItem idParam ->
            ( model
            , jumpToId idParam
            )

        Msg.UserClickedSearchResultForPreview url ->
            let
                oldSearch =
                    model.activeSearch

                newSearch =
                    { oldSearch
                        | preview = Loading
                        , selectedResult = Just url
                    }
            in
            ( { model | activeSearch = newSearch }
            , createRequest Msg.ServerRespondedWithPreview recordResponseDecoder url
            )

        Msg.UserClickedRecordViewTab tab ->
            let
                oldPage =
                    model.page

                newPage =
                    { oldPage | currentTab = tab }

                cmd =
                    case tab of
                        PersonSourcesRecordSearchTab url ->
                            createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder url

                        InstitutionSourcesRecordSearchTab url ->
                            createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder url

                        _ ->
                            Cmd.none
            in
            ( { model | page = newPage }
            , cmd
            )

        Msg.ClientJumpedToId ->
            ( model, Cmd.none )

        Msg.ClientResetViewport ->
            ( model, Cmd.none )

        Msg.UserClickedSearchResultsPagination url ->
            let
                cmd =
                    Cmd.batch
                        [ Nav.pushUrl model.key url

                        --, createRequest Msg.ServerRespondedWithData recordResponseDecoder url
                        , resetViewportOf "search-results-list"
                        ]
            in
            ( model, cmd )

        Msg.UserClickedRecordViewTabPagination url ->
            let
                cmd =
                    Cmd.batch
                        [ createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder url
                        , resetViewport
                        ]
            in
            ( model, cmd )

        Msg.UserClickedPageSearchSubmitButton baseUrl ->
            let
                page =
                    model.page

                pageQuery =
                    page.searchParams

                queryParameters =
                    buildQueryParameters pageQuery.query

                qString =
                    Url.Builder.toQuery queryParameters

                queryUrl =
                    baseUrl ++ qString

                cmd =
                    createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder queryUrl
            in
            ( model, cmd )

        Msg.UserInputTextInPageQueryBox qtext ->
            let
                page =
                    model.page

                oldSearchParams =
                    page.searchParams

                oldQueryParams =
                    oldSearchParams.query

                pageQuery =
                    if String.isEmpty qtext then
                        Nothing

                    else
                        Just qtext

                newQueryParams =
                    { oldQueryParams | query = pageQuery }

                newSearchParams =
                    { oldSearchParams | query = newQueryParams }

                newPage =
                    { page | searchParams = newSearchParams }
            in
            ( { model | page = newPage }
            , Cmd.none
            )

        Msg.UserClickedClosePreviewWindow ->
            let
                oldSearch =
                    model.activeSearch

                newSearch =
                    { oldSearch | preview = NoResponseToShow }
            in
            ( { model | activeSearch = newSearch }
            , Cmd.none
            )

        Msg.UserClickedRemoveActiveFilter activeAlias activeValue ->
            let
                oldSearch =
                    model.activeSearch

                oldQuery =
                    oldSearch.query

                newFilters =
                    List.filter
                        (\(Filter filterAlias filterValue) ->
                            not ((filterAlias == activeAlias) && (filterValue == activeValue))
                        )
                        oldQuery.filters

                newQuery =
                    { oldQuery | filters = newFilters }

                newSearch =
                    { oldSearch | query = newQuery }

                newModel =
                    { model | activeSearch = newSearch }
            in
            Search.searchSubmit newModel

        Msg.NothingHappened ->
            -- Use for mocking in a Msg that does nothing; For actual code, favour adding
            -- an explicit message for 'NoOp' updates.
            ( model, Cmd.none )
