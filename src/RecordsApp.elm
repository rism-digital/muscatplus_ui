module RecordsApp exposing (..)

import Api.Records exposing (ApiResponse(..), recordRequest)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Http exposing (Error(..))
import Language exposing (parseLocaleToLanguage)
import Records.DataTypes exposing (Model, Msg(..), parseUrl)
import Records.Views exposing (renderBody)
import Url exposing (Url)


type alias Flags =
    { locale : String }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedRecordResponse (Ok response) ->
            ( { model | response = Response response }, Cmd.none )

        ReceivedRecordResponse (Err error) ->
            let
                errorMessage =
                    case error of
                        BadUrl url ->
                            "A Bad URL was supplied: " ++ url

                        BadBody message ->
                            "Incorrect body received: " ++ message

                        _ ->
                            "A problem happened with the request"
            in
            ( { model | response = ApiError, errorMessage = errorMessage }, Cmd.none )

        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Hello Records!"
    , body = renderBody model
    }


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage
    in
    ( Model key initialUrl Loading "" language, recordRequest ReceivedRecordResponse initialUrl.path )


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
