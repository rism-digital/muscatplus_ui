module Main exposing (..)

import Browser
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
import DataTypes exposing (ApiResponse(..), Flags, Model, Msg(..), Route(..), ServerResponse(..), convertFacetToFilter, convertFacetToResultMode, defaultSearchQueryArgs)
import Http exposing (Error(..))
import Language exposing (parseLocaleToLanguage)
import List.Extra as LE
import Ports.LocalStorage exposing (saveLanguagePreference)
import Records.View exposing (viewRecordBody)
import Routes exposing (buildQueryParameters, parseUrl, requestFromServer, serverUrl)
import Search.View exposing (viewSearchBody)
import UI.Layout exposing (detectDevice)
import Url exposing (Url)
import Url.Builder as Builder


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedServerResponse (Ok response) ->
            ( { model | response = Response response }
            , Cmd.none
            )

        ReceivedServerResponse (Err error) ->
            let
                errorMessage =
                    case error of
                        BadUrl url ->
                            "A Bad URL was supplied: " ++ url

                        BadBody message ->
                            "Unexpected response: " ++ message

                        _ ->
                            "A problem happened with the request"
            in
            ( { model | errorMessage = errorMessage, response = ApiError }, Cmd.none )

        SearchInput textInput ->
            let
                activeSearch =
                    model.activeSearch

                currentQ =
                    activeSearch.query

                newInp =
                    if String.isEmpty textInput then
                        Nothing

                    else
                        Just textInput

                newQ =
                    DataTypes.SearchQueryArgs newInp currentQ.filters currentQ.sort 1 currentQ.mode

                newActiveSearch =
                    { activeSearch | query = newQ }
            in
            ( { model | activeSearch = newActiveSearch }, Cmd.none )

        SearchSubmit ->
            let
                activeSearch =
                    model.activeSearch

                urlBase =
                    "/search"

                url =
                    serverUrl [ "search" ] (buildQueryParameters activeSearch.query)
            in
            ( { model | response = Loading }
            , Cmd.batch
                [ requestFromServer ReceivedServerResponse urlBase activeSearch.query
                , Nav.pushUrl model.key url
                ]
            )

        OnWindowResize device ->
            ( { model | viewingDevice = device }, Cmd.none )

        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                parsedUrl =
                    parseUrl url

                activeSearch =
                    model.activeSearch

                activeQuery =
                    activeSearch.query

                cmd =
                    case parsedUrl of
                        FrontPageRoute ->
                            Cmd.none

                        _ ->
                            requestFromServer ReceivedServerResponse url.path activeQuery
            in
            ( { model | url = url, currentRoute = parsedUrl }
            , cmd
            )

        LanguageSelectChanged str ->
            ( { model | language = parseLocaleToLanguage str }
            , saveLanguagePreference str
            )

        FacetChecked facetname itm checked ->
            let
                activeSearch =
                    model.activeSearch

                facetConvertedToFilter =
                    convertFacetToFilter facetname itm

                currentQuery =
                    activeSearch.query

                currentFilters =
                    currentQuery.filters

                newFilters =
                    if checked then
                        facetConvertedToFilter :: currentFilters

                    else
                        LE.remove facetConvertedToFilter currentFilters

                newQuery =
                    { currentQuery | filters = newFilters, page = 1 }

                newActiveSearch =
                    { activeSearch | query = newQuery }
            in
            update SearchSubmit { model | activeSearch = newActiveSearch }

        ModeChecked _ itm _ ->
            let
                activeSearch =
                    model.activeSearch

                facetConvertedToResultMode =
                    convertFacetToResultMode itm

                currentQuery =
                    activeSearch.query

                newQuery =
                    { currentQuery | mode = facetConvertedToResultMode, filters = [] }

                newActiveSearch =
                    { activeSearch | selectedMode = facetConvertedToResultMode, query = newQuery }
            in
            update SearchSubmit { model | activeSearch = newActiveSearch }

        ToggleExpandFacet facetAlias ->
            let
                activeSearch =
                    model.activeSearch

                isInExpandedList =
                    List.member facetAlias activeSearch.expandedFacets

                newExpandedList =
                    if isInExpandedList then
                        LE.remove facetAlias activeSearch.expandedFacets

                    else
                        facetAlias :: activeSearch.expandedFacets

                newActiveSearch =
                    { activeSearch | expandedFacets = newExpandedList }
            in
            ( { model | activeSearch = newActiveSearch }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        pageView =
            case model.currentRoute of
                FrontPageRoute ->
                    viewSearchBody model

                SearchPageRoute _ ->
                    viewSearchBody model

                _ ->
                    viewRecordBody model
    in
    { title = "Search RISM Online"
    , body =
        pageView
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage

        route =
            parseUrl initialUrl

        initialQuery =
            case route of
                SearchPageRoute queryargs ->
                    queryargs

                _ ->
                    defaultSearchQueryArgs

        initialMode =
            initialQuery.mode

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        cmd =
            case route of
                FrontPageRoute ->
                    Cmd.none

                _ ->
                    requestFromServer ReceivedServerResponse initialUrl.path initialQuery

        initialActiveSearch =
            { selectedMode = initialMode
            , expandedFacets = []
            , query = initialQuery
            }
    in
    ( { key = key
      , url = initialUrl
      , currentRoute = route
      , activeSearch = initialActiveSearch
      , response = Loading
      , errorMessage = ""
      , language = language
      , viewingDevice = initialDevice
      }
    , cmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize <|
            \width height -> OnWindowResize (detectDevice width height)
        ]


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequest
        }
