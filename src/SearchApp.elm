module SearchApp exposing (..)

import Api.Search exposing (ApiResponse(..), SearchQueryArgs, searchRequest)
import Browser
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
import Config
import Http exposing (Error(..))
import Language exposing (Language, parseLocaleToLanguage)
import Search.DataTypes exposing (Model, Msg(..), Route(..), parseUrl, routeMatches)
import Search.Views exposing (viewSearchBody)
import UI.Layout exposing (detectDevice)
import Url exposing (Url)


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

        SearchInput { query } ->
            let
                newq =
                    SearchQueryArgs query [] ""
            in
            if String.length query > Config.minimumQueryLength then
                ( { model | query = newq }, Cmd.none )

            else
                ( { model | query = newq }, Cmd.none )

        SearchSubmit ->
            let
                queryModel =
                    model.query
            in
            ( { model | response = Loading }
            , Cmd.batch
                [ searchRequest ReceivedSearchResponse queryModel
                , Nav.pushUrl model.key "/search"
                ]
            )

        OnWindowResize device ->
            ( { model | viewingDevice = device }, Cmd.none )

        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    let
                        cmd =
                            case routeMatches url of
                                Just _ ->
                                    Nav.pushUrl model.key (Url.toString url)

                                Nothing ->
                                    Nav.load (Url.toString url)
                    in
                    ( model, cmd )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChange url ->
            ( { model | url = url, currentRoute = parseUrl url }, Cmd.none )

        LanguageSelectChanged str ->
            ( { model | language = parseLocaleToLanguage str }, Cmd.none )

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

        initialQuery =
            SearchQueryArgs "" [] ""

        initialErrorMessage =
            ""

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        initialRoute =
            parseUrl initialUrl
    in
    ( { key = key
      , url = initialUrl
      , response = Loading
      , errorMessage = initialErrorMessage
      , viewingDevice = initialDevice
      , language = language
      , currentRoute = initialRoute
      , query = initialQuery
      }
    , searchRequest ReceivedSearchResponse initialQuery
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
