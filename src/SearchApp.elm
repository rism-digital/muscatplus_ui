module SearchApp exposing (..)

import Api.Search exposing (ApiResponse(..), SearchQueryArgs, searchRequest)
import Browser
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
import Config
import Http exposing (Error(..))
import Language exposing (Language, parseLocaleToLanguage)
import Search.DataTypes exposing (Model, Msg(..), parseUrl)
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
            ( { model | response = Loading }, searchRequest ReceivedSearchResponse queryModel )

        OnWindowResize device ->
            ( { model | viewingDevice = device }, Cmd.none )

        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChange url ->
            ( { model | url = url }, Cmd.none )

        LanguageSelectChanged str ->
            ( { model | language = parseLocaleToLanguage str }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "RISM Online"
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
    ( Model key initialUrl initialQuery NoResponseToShow initialErrorMessage initialDevice language initialRoute, Cmd.none )


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
