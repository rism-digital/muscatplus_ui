module SearchApp exposing (..)

import Browser
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
import Http exposing (Error(..))
import List.Extra as LE
import Search.DataTypes exposing (ApiResponse(..), Model, Msg(..), Route(..), SearchQueryArgs, convertFacetToFilter, convertFacetToResultMode, defaultModeFilter, defaultSearchQueryArgs, parseUrl, routeMatches)
import Search.Routes exposing (buildQueryParameters, searchRequest)
import Search.Views.View exposing (viewSearchBody)
import Shared.Language exposing (Language, parseLocaleToLanguage)
import UI.Layout exposing (detectDevice)
import Url exposing (Url)
import Url.Builder as Builder


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedSearchResponse (Ok response) ->
            ( { model | response = Response response }, Cmd.none )

        ReceivedSearchResponse (Err error) ->
            let
                errorMessage =
                    case error of
                        BadUrl url ->
                            "A Bad URL was supplied: " ++ url

                        _ ->
                            "A problem happened with the request"
            in
            ( { model | errorMessage = errorMessage, response = ApiError }, Cmd.none )

        SearchInput textInput ->
            let
                currentQ =
                    model.query

                newInp =
                    if String.isEmpty textInput then
                        Nothing

                    else
                        Just textInput

                newQ =
                    SearchQueryArgs newInp currentQ.filters currentQ.sort 1 currentQ.mode
            in
            ( { model | query = newQ }, Cmd.none )

        SearchSubmit ->
            let
                queryModel =
                    model.query
            in
            ( { model | response = Loading }
            , Cmd.batch
                [ searchRequest ReceivedSearchResponse queryModel
                , Nav.pushUrl model.key ("/search" ++ Builder.toQuery (buildQueryParameters model.query))
                ]
            )

        OnWindowResize device ->
            ( { model | viewingDevice = device }, Cmd.none )

        UrlRequest urlRequest ->
            case urlRequest of
                -- Elm will assume that any host name that starts with the same host name
                -- as the current page is an internal URL. This causes problems for switching
                -- pages that are not handled by Elm. So, when Elm detects an 'Internal' URL
                -- we check it against our defined routes. If it matches, then we treat it
                -- as an internal URL; if it doesn't match, we treat it as an external one.
                Browser.Internal url ->
                    let
                        query =
                            case parseUrl url of
                                SearchPageRoute qp ->
                                    qp

                                FrontPageRoute ->
                                    defaultSearchQueryArgs

                                _ ->
                                    model.query

                        state =
                            case routeMatches url of
                                Just _ ->
                                    ( { model | url = url, currentRoute = parseUrl url, query = query }
                                    , Cmd.batch
                                        [ searchRequest ReceivedSearchResponse query
                                        , Nav.pushUrl model.key (Url.toString url)
                                        ]
                                    )

                                Nothing ->
                                    ( model, Nav.load (Url.toString url) )
                    in
                    state

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChange url ->
            ( { model | url = url, currentRoute = parseUrl url }, Cmd.none )

        LanguageSelectChanged str ->
            ( { model | language = parseLocaleToLanguage str }, Cmd.none )

        FacetChecked facetname itm checked ->
            let
                currentlySelected =
                    model.selectedFilters

                facetConvertedToFilter =
                    convertFacetToFilter facetname itm

                newSelected =
                    if List.member facetConvertedToFilter currentlySelected then
                        LE.remove facetConvertedToFilter currentlySelected

                    else
                        facetConvertedToFilter :: currentlySelected

                currentQuery =
                    model.query

                currentFilters =
                    currentQuery.filters

                newFilters =
                    if checked then
                        facetConvertedToFilter :: currentFilters

                    else
                        LE.remove facetConvertedToFilter currentFilters

                newQuery =
                    { currentQuery | filters = newFilters, page = 1 }
            in
            update SearchSubmit { model | query = newQuery, selectedFilters = newSelected }

        ModeChecked _ itm _ ->
            let
                facetConvertedToResultMode =
                    convertFacetToResultMode itm

                currentQuery =
                    model.query

                newQuery =
                    { currentQuery | mode = facetConvertedToResultMode, filters = [] }
            in
            update SearchSubmit { model | selectedMode = facetConvertedToResultMode, query = newQuery, selectedFilters = [] }

        ToggleExpandFacet facetAlias ->
            let
                isInExpandedList =
                    List.member facetAlias model.expandedFacets

                newExpandedList =
                    if isInExpandedList then
                        LE.remove facetAlias model.expandedFacets

                    else
                        facetAlias :: model.expandedFacets
            in
            ( { model | expandedFacets = newExpandedList }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Search RISM Online"
    , body =
        viewSearchBody model
    }


type alias Flags =
    { locale : String
    , windowWidth : Int
    , windowHeight : Int
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

        initialErrorMessage =
            ""

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        initialRoute =
            parseUrl initialUrl

        initialCmd =
            case route of
                SearchPageRoute _ ->
                    searchRequest ReceivedSearchResponse initialQuery

                _ ->
                    Cmd.none

        initialMode =
            initialQuery.mode
    in
    ( { key = key
      , url = initialUrl
      , response = Loading
      , errorMessage = initialErrorMessage
      , viewingDevice = initialDevice
      , language = language
      , currentRoute = initialRoute
      , query = initialQuery
      , selectedFilters = []
      , selectedMode = initialMode
      , expandedFacets = []
      }
    , initialCmd
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
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }
