module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Http exposing (Error(..))
import Language exposing (parseLocaleToLanguage)
import List.Extra as LE
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Converters exposing (convertFacetToResultMode)
import Page.Decoders exposing (recordResponseDecoder)
import Page.Model exposing (CurrentRecordViewTab(..), Response(..))
import Page.Query exposing (Filter(..), buildQueryParameters)
import Page.Route exposing (Route(..), parseUrl)
import Ports.LocalStorage exposing (saveLanguagePreference)
import Request exposing (createRequest, serverUrl)
import Url
import Viewport exposing (jumpToId, resetViewport)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.ServerRespondedWithData (Ok response) ->
            let
                oldPage =
                    model.page

                newResponse =
                    { oldPage | response = Response response }
            in
            ( { model | page = newResponse }, Cmd.none )

        Msg.ServerRespondedWithData (Err error) ->
            let
                oldPage =
                    model.page

                errorMessage =
                    case error of
                        BadUrl url ->
                            "A Bad URL was supplied: " ++ url

                        BadBody message ->
                            "Unexpected response: " ++ message

                        _ ->
                            "A problem happened with the request"

                newResponse =
                    { oldPage | response = Error errorMessage }
            in
            ( { model | page = newResponse }, Cmd.none )

        Msg.ServerRespondedWithPreview (Ok response) ->
            let
                oldSearch =
                    model.activeSearch

                newSearch =
                    { oldSearch | preview = Response response }
            in
            ( { model | activeSearch = newSearch }, Cmd.none )

        Msg.ServerRespondedWithPreview (Err _) ->
            ( model, Cmd.none )

        Msg.ServerRespondedWithPageSearch (Ok response) ->
            let
                oldPage =
                    model.page

                newPage =
                    { oldPage | pageSearch = Response response }
            in
            ( { model | page = newPage }, Cmd.none )

        Msg.ServerRespondedWithPageSearch (Err error) ->
            let
                errorMessage =
                    case error of
                        BadUrl url ->
                            "A Bad URL was supplied: " ++ url

                        BadBody message ->
                            "Unexpected response: " ++ message

                        _ ->
                            "A problem happened with the request"

                oldPage =
                    model.page

                newPage =
                    { oldPage | pageSearch = Error errorMessage }
            in
            ( { model | page = newPage }, Cmd.none )

        Msg.ClientChangedUrl url ->
            let
                oldPage =
                    model.page

                newRoute =
                    parseUrl url

                newPage =
                    { oldPage
                        | route = newRoute
                        , currentTab = DefaultRecordViewTab
                        , pageSearch = NoResponseToShow
                    }

                newQuery =
                    case newRoute of
                        SearchPageRoute qargs ->
                            buildQueryParameters qargs

                        _ ->
                            []

                newUrl =
                    serverUrl [ url.path ] newQuery
            in
            ( { model | page = newPage }
            , Cmd.batch
                [ createRequest Msg.ServerRespondedWithData recordResponseDecoder newUrl
                , resetViewport
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

        Msg.UserClickedSearchSubmitButton ->
            let
                oldPage =
                    model.page

                newPage =
                    { oldPage | response = Page.Model.Loading }

                activeSearch =
                    model.activeSearch

                newSearch =
                    { activeSearch | preview = NoResponseToShow }

                url =
                    serverUrl [ "search" ] (buildQueryParameters activeSearch.query)
            in
            ( { model | page = newPage, activeSearch = newSearch }
              -- this will trigger UrlChanged, which will actually submit the
              -- URL and request the data from the server.
            , Nav.pushUrl model.key url
            )

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
            update Msg.UserClickedSearchSubmitButton newModel

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
            update Msg.UserClickedSearchSubmitButton newModel

        Msg.UserClickedFacetItem _ _ _ ->
            ( model, Cmd.none )

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

        Msg.UserClickedRecordViewTabPagination url ->
            let
                cmd =
                    Cmd.batch
                        [ createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder url
                        , resetViewport
                        ]
            in
            ( model, cmd )

        Msg.UserClickedClosePreviewWindow ->
            let
                oldSearch =
                    model.activeSearch

                newSearch =
                    { oldSearch | preview = NoResponseToShow }
            in
            ( { model | activeSearch = newSearch }, Cmd.none )

        Msg.NothingHappened ->
            -- Use for mocking in a Msg that does nothing; For actual code, favour adding
            -- an explicit message for 'NoOp' updates.
            ( model, Cmd.none )
