module RecordsApp exposing (..)

import Api.Records exposing (ApiResponse(..), recordRequest)
import Browser
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
import Http exposing (Error(..))
import Language exposing (parseLocaleToLanguage)
import Records.DataTypes exposing (Model, Msg(..))
import Records.Views.View as View exposing (viewRecordBody)
import UI.Layout exposing (detectDevice)
import Url exposing (Url)


type alias Flags =
    { locale : String
    , windowWidth : Int
    , windowHeight : Int
    }


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
            ( { model | url = url }, recordRequest ReceivedRecordResponse url.path )

        OnWindowResize device ->
            ( { model | viewingDevice = device }, Cmd.none )

        LanguageSelectChanged str ->
            ( { model | language = parseLocaleToLanguage str }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    View.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize <|
            \width height -> OnWindowResize (detectDevice width height)
        ]


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight
    in
    ( { key = key
      , url = initialUrl
      , response = Loading
      , errorMessage = ""
      , language = language
      , viewingDevice = initialDevice
      }
    , recordRequest ReceivedRecordResponse initialUrl.path
    )


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
