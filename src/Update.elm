module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Http exposing (Error(..))
import Language exposing (parseLocaleToLanguage)
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Converters exposing (convertFacetToResultMode)
import Page.Decoders exposing (recordResponseDecoder)
import Page.Model exposing (Response(..))
import Page.Query exposing (buildQueryParameters)
import Page.Route exposing (Route(..), parseUrl)
import Ports.LocalStorage exposing (saveLanguagePreference)
import Request exposing (createRequest, serverUrl)
import Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.ReceivedServerResponse (Ok response) ->
            let
                oldPage =
                    model.page

                newResponse =
                    { oldPage | response = Response response }
            in
            ( { model | page = newResponse }, Cmd.none )

        Msg.ReceivedServerResponse (Err error) ->
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

        Msg.ReceivedPreviewResponse (Ok response) ->
            let
                oldSearch =
                    model.activeSearch

                newSearch =
                    { oldSearch | preview = Response response }
            in
            ( { model | activeSearch = newSearch }, Cmd.none )

        Msg.ReceivedPreviewResponse (Err error) ->
            ( model, Cmd.none )

        Msg.UrlChanged url ->
            let
                oldPage =
                    model.page

                newRoute =
                    parseUrl url

                newPage =
                    { oldPage | route = newRoute }

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
            , createRequest Msg.ReceivedServerResponse recordResponseDecoder newUrl
            )

        Msg.OnWindowResize device ->
            ( { model | device = device }, Cmd.none )

        Msg.UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        Msg.LanguageSelectChanged lang ->
            ( { model | language = parseLocaleToLanguage lang }
            , saveLanguagePreference lang
            )

        Msg.SearchSubmit ->
            let
                oldPage =
                    model.page

                newPage =
                    { oldPage | response = Page.Model.Loading }

                activeSearch =
                    model.activeSearch

                url =
                    serverUrl [ "search" ] (buildQueryParameters activeSearch.query)
            in
            ( { model | page = newPage }
              -- this will trigger UrlChanged, which will actually submit the
              -- URL and request the data from the server.
            , Nav.pushUrl model.key url
            )

        Msg.SearchInput qtext ->
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

        Msg.ModeSelected _ itm _ ->
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
                    { oldSearch | query = newQuery, selectedMode = facetConvertedToResultMode }

                newModel =
                    { model | activeSearch = newSearch }
            in
            update Msg.SearchSubmit newModel

        Msg.FacetChecked _ _ _ ->
            ( model, Cmd.none )

        Msg.PreviewSearchResult url ->
            let
                oldSearch =
                    model.activeSearch

                newSearch =
                    { oldSearch | preview = Loading }
            in
            ( { model | activeSearch = newSearch }
            , createRequest Msg.ReceivedPreviewResponse recordResponseDecoder url
            )

        Msg.NoOp ->
            ( model, Cmd.none )
