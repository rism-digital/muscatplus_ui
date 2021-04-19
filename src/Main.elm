module Main exposing (..)

import Browser
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
import DataTypes exposing (ApiResponse(..), Flags, Model, Msg(..), Route(..), ServerResponse(..), convertFacetToFilter, convertFacetToResultMode, defaultSearchQueryArgs)
import Http exposing (Error(..))
import Language exposing (parseLocaleToLanguage)
import List.Extra as LE
import Records.View exposing (viewRecordBody)
import Routes exposing (buildQueryParameters, parseUrl, requestFromServer, routeMatches)
import Search.View exposing (viewSearchBody)
import UI.Layout exposing (detectDevice)
import Url exposing (Url)
import Url.Builder as Builder


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedServerResponse (Ok response) ->
            ( { model | response = Response response }, Cmd.none )

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
                currentQ =
                    model.query

                newInp =
                    if String.isEmpty textInput then
                        Nothing

                    else
                        Just textInput

                newQ =
                    DataTypes.SearchQueryArgs newInp currentQ.filters currentQ.sort 1 currentQ.mode
            in
            ( { model | query = newQ }, Cmd.none )

        SearchSubmit ->
            let
                url =
                    "/search" ++ Builder.toQuery (buildQueryParameters model.query)
            in
            ( { model | response = Loading }
            , Cmd.batch
                [ requestFromServer ReceivedServerResponse url
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

                cmd =
                    case parsedUrl of
                        FrontPageRoute ->
                            Cmd.none

                        _ ->
                            requestFromServer ReceivedServerResponse url.path
            in
            ( { model | url = url, currentRoute = parsedUrl }
            , cmd
            )

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
                    requestFromServer ReceivedServerResponse initialUrl.path
    in
    ( { key = key
      , url = initialUrl
      , currentRoute = route
      , selectedMode = initialMode
      , selectedFilters = []
      , expandedFacets = []
      , query = initialQuery
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
