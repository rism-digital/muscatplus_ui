module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Device exposing (setDevice)
import Language exposing (parseLocaleToLanguage, setLanguage)
import Model exposing (Model(..), toSession, updateSession)
import Msg exposing (Msg)
import Page.Front as FrontPage
import Page.NotFound as NotFoundPage
import Page.Record as RecordPage
import Page.Route as Route exposing (parseUrl, setRoute, setUrl)
import Page.Search as SearchPage
import Page.SideBar as SideBar
import Ports.LocalStorage exposing (saveLanguagePreference)
import Url exposing (Url)
import Utlities exposing (flip)


changePage : Url -> Model -> ( Model, Cmd Msg )
changePage url model =
    let
        route =
            parseUrl url

        newSession =
            toSession model
                |> setRoute route
                |> setUrl url
    in
    case route of
        Route.FrontPageRoute ->
            ( FrontPage newSession FrontPage.init
            , Cmd.map Msg.UserInteractedWithFrontPage (FrontPage.frontPageRequest url)
            )

        Route.NotFoundPageRoute ->
            ( NotFoundPage newSession NotFoundPage.init
            , Cmd.none
            )

        Route.SearchPageRoute _ _ ->
            let
                -- set the old data on the Loading response
                -- so that the view keeps the old appearance until
                -- the new data is loaded. In the case where we're
                -- coming from another page, or the response doesn't
                -- already contain server data we instead initialize
                -- a default search page model.
                newPageModel =
                    case model of
                        SearchPage _ pageModel ->
                            SearchPage.load pageModel

                        _ ->
                            SearchPage.init route
            in
            ( SearchPage newSession newPageModel
            , Cmd.map Msg.UserInteractedWithSearchPage (SearchPage.searchPageRequest url)
            )

        Route.SourcePageRoute _ ->
            ( SourcePage newSession (RecordPage.init route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.PersonPageRoute _ ->
            ( PersonPage newSession (RecordPage.init route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.InstitutionPageRoute _ ->
            ( InstitutionPage newSession (RecordPage.init route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.PlacePageRoute _ ->
            ( PlacePage newSession (RecordPage.init route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        _ ->
            ( NotFoundPage newSession NotFoundPage.init, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Msg.ClientChangedUrl url, _ ) ->
            changePage url model

        ( Msg.UserChangedLanguageSelect language, _ ) ->
            let
                newModel =
                    toSession model
                        |> setLanguage (parseLocaleToLanguage language)
                        |> flip updateSession model
            in
            ( newModel
            , saveLanguagePreference language
            )

        ( Msg.UserRequestedUrlChange urlRequest, _ ) ->
            let
                session =
                    toSession model
            in
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( Msg.UserResizedWindow device, _ ) ->
            let
                newModel =
                    toSession model
                        |> setDevice device
                        |> flip updateSession model
            in
            ( newModel, Cmd.none )

        ( Msg.UserInteractedWithSideBar sideBarMsg, _ ) ->
            let
                ( newSession, sidebarCmd ) =
                    toSession model
                        |> SideBar.update sideBarMsg

                newModel =
                    updateSession newSession model
            in
            ( newModel
            , Cmd.map Msg.UserInteractedWithSideBar sidebarCmd
            )

        ( Msg.UserInteractedWithFrontPage frontMsg, FrontPage session pageModel ) ->
            FrontPage.update frontMsg pageModel
                |> updateWith (FrontPage session) Msg.UserInteractedWithFrontPage model

        ( Msg.UserInteractedWithSearchPage searchMsg, SearchPage session pageModel ) ->
            SearchPage.update session searchMsg pageModel
                |> updateWith (SearchPage session) Msg.UserInteractedWithSearchPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, SourcePage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (SourcePage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, PersonPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (PersonPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, InstitutionPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (InstitutionPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, PlacePage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (PlacePage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithNotFoundPage notFoundMsg, NotFoundPage session pageModel ) ->
            NotFoundPage.update session notFoundMsg pageModel
                |> updateWith (NotFoundPage session) Msg.UserInteractedWithNotFoundPage model

        ( Msg.NothingHappened, _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



--update : Msg -> Model -> ( Model, Cmd Msg )
--update msg model =
--    case msg of
--Msg.ServerRespondedWithData (Ok ( metadata, response )) ->
--    Page.Response.DataResponse.serverRespondedWithData model response
--
--Msg.ServerRespondedWithData (Err error) ->
--    Page.Response.DataResponse.serverRespondedWithDataError model error
--
--Msg.ServerRespondedWithPreview (Ok ( metadata, response )) ->
--    Page.Response.PreviewResponse.serverRespondedWithPreview model response
--
--Msg.ServerRespondedWithPreview (Err error) ->
--    Page.Response.PreviewResponse.serverRespondedWithPreviewError model error
--
--Msg.ServerRespondedWithPageSearch (Ok ( metadata, response )) ->
--    Page.Response.PageSearchResponse.serverRespondedWithPageSearch model response
--
--Msg.ServerRespondedWithPageSearch (Err error) ->
--    Page.Response.PageSearchResponse.serverRespondedWithPageSearchError model error
--
--Msg.ClientChangedUrl url ->
--    let
--        oldPage =
--            model.page
--
--        newRoute =
--            parseUrl url
--
--        activeSearch =
--            case newRoute of
--                FrontPageRoute ->
--                    Search.init newRoute
--
--                _ ->
--                    model.activeSearch
--
--        newPage =
--            { oldPage
--                | route = newRoute
--                , currentTab = DefaultRecordViewTab
--                , searchResults = NoResponseToShow
--            }
--
--        newQuery =
--            case newRoute of
--                SearchPageRoute qargs nargs ->
--                    List.append (buildQueryParameters qargs) (buildNotationQueryParameters nargs)
--
--                _ ->
--                    []
--
--        newUrl =
--            serverUrl [ url.path ] newQuery
--    in
--    ( { model
--        | page = newPage
--        , activeSearch = activeSearch
--      }
--    , Cmd.batch
--        [ createRequest Msg.ServerRespondedWithData recordResponseDecoder newUrl
--        ]
--    )
--
--Msg.UserResizedWindow device ->
--    ( { model | device = device }, Cmd.none )
--
--Msg.UserRequestedUrlChange urlRequest ->
--    case urlRequest of
--        Browser.Internal url ->
--            ( model, Nav.pushUrl model.key (Url.toString url) )
--
--        Browser.External href ->
--            ( model, Nav.load href )
--
--Msg.UserChangedLanguageSelect lang ->
--    ( { model | language = parseLocaleToLanguage lang }
--    , saveLanguagePreference lang
--    )
--Msg.UserChangedResultSorting sort ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        oldQuery =
--            oldSearch.query
--
--        -- even though this is a 'Maybe' value, if the user goes through
--        -- the trouble of selecting a new sort then we explicitly use that.
--        sortValue =
--            Just sort
--
--        newQuery =
--            { oldQuery | sort = sortValue }
--
--        newSearch =
--            { oldSearch
--                | selectedResultSort = sortValue
--                , query = newQuery
--            }
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    Search.searchSubmit newModel
--
--Msg.UserTriggeredSearchSubmit ->
--    Search.searchSubmit model
--
--Msg.UserInputTextInQueryBox qtext ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        oldQueryParams =
--            oldSearch.query
--
--        newQuery =
--            if String.isEmpty qtext then
--                Nothing
--
--            else
--                Just qtext
--
--        newQueryParams =
--            { oldQueryParams | query = newQuery }
--
--        newSearch =
--            { oldSearch | query = newQueryParams }
--    in
--    ( { model | activeSearch = newSearch }, Cmd.none )
--
--Msg.UserClickedModeItem _ itm _ ->
--    let
--        facetConvertedToResultMode =
--            convertFacetToResultMode itm
--
--        oldSearch =
--            model.activeSearch
--
--        oldQuery =
--            oldSearch.query
--
--        newQuery =
--            { oldQuery | mode = facetConvertedToResultMode }
--
--        newSearch =
--            { oldSearch
--                | query = newQuery
--                , selectedMode = facetConvertedToResultMode
--                , selectedResult = Nothing
--            }
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    Search.searchSubmit newModel
--
--Msg.UserClickedFacetToggle label ->
--    let
--        activeSearch =
--            model.activeSearch
--
--        query =
--            activeSearch.query
--
--        activeFilters =
--            query.filters
--
--        filter =
--            Filter label "true"
--
--        newFilters =
--            if List.member filter activeFilters == True then
--                LE.remove filter activeFilters
--
--            else
--                filter :: activeFilters
--
--        newQuery =
--            { query | filters = newFilters }
--
--        newSearch =
--            { activeSearch | query = newQuery }
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    Search.searchSubmit newModel
--
--Msg.UserClickedFacetExpand alias ->
--    let
--        activeSearch =
--            model.activeSearch
--
--        expandedFacets =
--            activeSearch.expandedFacets
--
--        isInExpandedList =
--            List.member alias expandedFacets
--
--        newExpandedList =
--            if isInExpandedList then
--                LE.remove alias expandedFacets
--
--            else
--                alias :: expandedFacets
--
--        newSearch =
--            { activeSearch | expandedFacets = newExpandedList }
--    in
--    ( { model | activeSearch = newSearch }, Cmd.none )
--
--Msg.UserClickedFacetItem alias facetItem isChecked ->
--    let
--        (FacetItem value label count) =
--            facetItem
--
--        activeSearch =
--            model.activeSearch
--
--        query =
--            activeSearch.query
--
--        activeFilters =
--            query.filters
--
--        asFilter =
--            convertFacetToFilter alias facetItem
--
--        newSelected =
--            if List.member asFilter activeFilters then
--                LE.remove asFilter activeFilters
--
--            else
--                asFilter :: activeFilters
--
--        newQuery =
--            { query | filters = newSelected }
--
--        newSearch =
--            { activeSearch | query = newQuery }
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    Search.searchSubmit newModel
--
--Msg.UserChangedFacetBehaviour behaviour ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        oldQuery =
--            oldSearch.query
--
--        oldBehaviours =
--            oldQuery.facetBehaviours
--
--        fieldAlias =
--            case behaviour of
--                IntersectionBehaviour f ->
--                    f
--
--                UnionBehaviour f ->
--                    f
--
--        -- filter the alias from the list of old behaviours, and then
--        -- add the new behaviour.
--        newBehaviours =
--            List.filter
--                (\b ->
--                    let
--                        aField =
--                            case b of
--                                IntersectionBehaviour alias ->
--                                    alias
--
--                                UnionBehaviour alias ->
--                                    alias
--                    in
--                    aField /= fieldAlias
--                )
--                oldBehaviours
--                |> (::) behaviour
--
--        newQuery =
--            { oldQuery | facetBehaviours = newBehaviours }
--
--        newSearch =
--            { oldSearch | query = newQuery }
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    Search.searchSubmit newModel
--
--Msg.UserChangedFacetSort sort ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        oldQuery =
--            oldSearch.query
--
--        oldSorts =
--            oldQuery.facetSorts
--
--        alias =
--            case sort of
--                CountSortOrder a ->
--                    a
--
--                AlphaSortOrder a ->
--                    a
--
--        -- overwrites the existing value with
--        -- a new one. The value
--        -- of sort is already swapped in the view function.
--        newSorts =
--            Dict.insert alias sort oldSorts
--
--        newQuery =
--            { oldQuery | facetSorts = newSorts }
--
--        newSearch =
--            { oldSearch | query = newQuery }
--
--        textQueryParameters =
--            buildQueryParameters newSearch.query
--
--        url =
--            serverUrl [ "search" ] textQueryParameters
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    ( newModel, Nav.pushUrl model.key url )
--
--Msg.UserChangedFacetMode mode ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        oldQuery =
--            oldSearch.query
--
--        oldModes =
--            oldQuery.facetModes
--
--        alias =
--            case mode of
--                CheckboxSelect a ->
--                    a
--
--                TextInputSelect a ->
--                    a
--
--        -- overwrites the existing value with
--        -- a new one. The value
--        -- of sort is already swapped in the view function.
--        newModes =
--            Dict.insert alias mode oldModes
--
--        newQuery =
--            { oldQuery | facetModes = newModes }
--
--        newSearch =
--            { oldSearch | query = newQuery }
--
--        textQueryParameters =
--            buildQueryParameters newSearch.query
--
--        url =
--            serverUrl [ "search" ] textQueryParameters
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    ( newModel, Nav.pushUrl model.key url )
--
--Msg.UserInteractedWithPianoKeyboard subMsg ->
--    Keyboard.update subMsg
--
--
--    let
--        page =
--            model.page
--
--        ( updatedModel, keyboardCmd ) =
--            case page of
--                SearchPage route pageModel ->
--                    let
--                        activeSearch =
--                            pageModel.activeSearch
--
--                        oldKeyboard =
--                            activeSearch.keyboard
--
--                        ( km, kc ) =
--                            Keyboard.update subMsg oldKeyboard
--
--                        newSearch =
--                            { activeSearch | keyboard = km }
--
--                        newPageModel =
--                            { pageModel | activeSearch = newSearch }
--
--                        newModel =
--                            { model | page = SearchPage route newPageModel }
--                    in
--                    ( newModel, kc )
--
--                --
--                --RecordPage route pageModel ->
--                _ ->
--                    ( model, Cmd.none )
--    in
--    ( updatedModel
--    , Cmd.map Msg.UserInteractedWithPianoKeyboard keyboardCmd
--    )
--
--Msg.UserClickedPianoKeyboardSearchSubmitButton ->
--    Search.searchSubmit model
--
--Msg.UserClickedPianoKeyboardSearchClearButton ->
--    let
--        newPageModel pm =
--            let
--                activeSearch =
--                    pm.activeSearch
--
--                -- Reset the keyboard to the initial state
--                newSearch =
--                    { activeSearch | keyboard = Keyboard.initModel }
--
--                newPm =
--                    { pm | activeSearch = newSearch }
--            in
--            newPm
--
--        ( m, c ) =
--            case model.page of
--                RecordPage routes pageModel ->
--                    let
--                        updatedPageModel =
--                            newPageModel pageModel
--
--                        newPage =
--                            RecordPage routes updatedPageModel
--
--                        newModel =
--                            { model | page = newPage }
--                    in
--                    Search.searchSubmit newModel
--
--                SearchPage routes pageModel ->
--                    let
--                        updatedPageModel =
--                            newPageModel pageModel
--
--                        newPage =
--                            SearchPage routes updatedPageModel
--
--                        newModel =
--                            { model | page = newPage }
--                    in
--                    Search.searchSubmit newModel
--
--                _ ->
--                    ( model, Cmd.none )
--    in
--    ( m, c )
--Msg.UserMovedRangeSlider sliderAlias sliderMsg ->
--    let
--        fireUpdate =
--            case sliderMsg of
--                RangeSlider.DragEnd _ ->
--                    True
--
--                _ ->
--                    False
--
--        oldSearch =
--            model.activeSearch
--
--        query =
--            oldSearch.query
--
--        oldFilters =
--            query.filters
--
--        oldSliders =
--            oldSearch.sliders
--
--        newSlider : Maybe RangeSlider
--        newSlider =
--            Dict.get sliderAlias oldSliders
--                |> Maybe.map (RangeSlider.update sliderMsg)
--
--        newSliders =
--            case newSlider of
--                Just sl ->
--                    Dict.insert sliderAlias sl oldSliders
--
--                Nothing ->
--                    oldSliders
--
--        newFilter : Maybe Filter
--        newFilter =
--            case newSlider of
--                Just sl ->
--                    let
--                        ( from, to ) =
--                            RangeSlider.getValues sl
--
--                        filterValue =
--                            "[" ++ String.fromFloat from ++ " TO " ++ String.fromFloat to ++ "]"
--
--                        thisFilt =
--                            if fireUpdate == True then
--                                Just (Filter sliderAlias filterValue)
--
--                            else
--                                Nothing
--                    in
--                    thisFilt
--
--                Nothing ->
--                    Nothing
--
--        -- remove any old occurrences of the filter
--        filteredFilters =
--            if fireUpdate == True then
--                List.filter (\(Filter l _) -> l /= sliderAlias) oldFilters
--
--            else
--                oldFilters
--
--        newFilters =
--            case newFilter of
--                Just f ->
--                    f :: filteredFilters
--
--                Nothing ->
--                    filteredFilters
--
--        newQuery =
--            { query | filters = newFilters }
--
--        newSearch =
--            { oldSearch | sliders = newSliders, query = newQuery }
--
--        newModel =
--            { model | activeSearch = newSearch }
--
--        url =
--            serverUrl [ "search" ] (buildQueryParameters newSearch.query)
--
--        cmd =
--            if fireUpdate == True then
--                Nav.pushUrl model.key url
--
--            else
--                Cmd.none
--    in
--    ( newModel, cmd )
--
--Msg.UserClickedToCItem idParam ->
--    ( model
--    , jumpToId idParam
--    )
--
--Msg.UserClickedSearchResultForPreview url ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        newSearch =
--            { oldSearch
--                | preview = Loading Nothing
--                , selectedResult = Just url
--            }
--    in
--    ( { model | activeSearch = newSearch }
--    , createRequest Msg.ServerRespondedWithPreview recordResponseDecoder url
--    )
--
--Msg.UserClickedRecordViewTab tab ->
--    let
--        oldPage =
--            model.page
--
--        newPage =
--            { oldPage | currentTab = tab }
--
--        cmd =
--            case tab of
--                PersonSourcesRecordSearchTab url ->
--                    createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder url
--
--                InstitutionSourcesRecordSearchTab url ->
--                    createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder url
--
--                _ ->
--                    Cmd.none
--    in
--    ( { model | page = newPage }
--    , cmd
--    )
--
--Msg.ClientJumpedToId ->
--    ( model, Cmd.none )
--
--Msg.ClientResetViewport ->
--    ( model, Cmd.none )
--
--Msg.UserClickedSearchResultsPagination url ->
--    let
--        cmd =
--            Cmd.batch
--                [ Nav.pushUrl model.key url
--                , resetViewportOf "search-results-list"
--                ]
--    in
--    ( model, cmd )
--
--Msg.UserClickedRecordViewTabPagination url ->
--    let
--        cmd =
--            Cmd.batch
--                [ createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder url
--                , resetViewport
--                ]
--    in
--    ( model, cmd )
--
--Msg.UserClickedPageSearchSubmitButton baseUrl ->
--    let
--        page =
--            model.page
--
--        pageQuery =
--            page.searchParams
--
--        queryParameters =
--            buildQueryParameters pageQuery.query
--
--        qString =
--            Url.Builder.toQuery queryParameters
--
--        queryUrl =
--            baseUrl ++ qString
--
--        cmd =
--            createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder queryUrl
--    in
--    ( model, cmd )
--
--Msg.UserInputTextInPageQueryBox qtext ->
--    let
--        page =
--            model.page
--
--        oldSearchParams =
--            page.searchParams
--
--        oldQueryParams =
--            oldSearchParams.query
--
--        pageQuery =
--            if String.isEmpty qtext then
--                Nothing
--
--            else
--                Just qtext
--
--        newQueryParams =
--            { oldQueryParams | query = pageQuery }
--
--        newSearchParams =
--            { oldSearchParams | query = newQueryParams }
--
--        newPage =
--            { page | searchParams = newSearchParams }
--    in
--    ( { model | page = newPage }
--    , Cmd.none
--    )
--
--Msg.UserClickedClosePreviewWindow ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        newSearch =
--            { oldSearch | preview = NoResponseToShow }
--    in
--    ( { model | activeSearch = newSearch }
--    , Cmd.none
--    )
--
--Msg.UserClickedRemoveActiveFilter activeAlias activeValue ->
--    let
--        oldSearch =
--            model.activeSearch
--
--        oldQuery =
--            oldSearch.query
--
--        newFilters =
--            List.filter
--                (\(Filter filterAlias filterValue) ->
--                    not ((filterAlias == activeAlias) && (filterValue == activeValue))
--                )
--                oldQuery.filters
--
--        newQuery =
--            { oldQuery | filters = newFilters }
--
--        newSearch =
--            { oldSearch | query = newQuery }
--
--        newModel =
--            { model | activeSearch = newSearch }
--    in
--    Search.searchSubmit newModel
--
--Msg.UserClickedClearSearchQueryBox ->
--    let
--        activeSearch =
--            model.activeSearch
--
--        activeQuery =
--            activeSearch.query
--
--        newActiveQuery =
--            { activeQuery | query = Nothing }
--
--        newActiveSearch =
--            { activeSearch | query = newActiveQuery }
--
--        newModel =
--            { model | activeSearch = newActiveSearch }
--    in
--    Search.searchSubmit newModel
--Msg.NothingHappened ->
--    -- Use for mocking in a Msg that does nothing; For actual code, favour adding
--    -- an explicit message for 'NoOp' updates.
--    ( model, Cmd.none )
