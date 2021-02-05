module SearchApp exposing (..)

import Api.Search exposing (ApiResponse(..), SearchQueryArgs, searchRequest)
import Browser
import Browser.Events exposing (onResize)
import Config
import Http exposing (Error(..))
import Language exposing (Language, parseLocaleToLanguage)
import Search.DataTypes exposing (Model, Msg(..))
import Search.Views exposing (viewSearchBody)
import UI.Layout exposing (detectDevice)


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

            else if String.length query == 0 then
                ( { model | query = newq }, Cmd.none )

            else
                ( model, Cmd.none )

        SearchSubmit ->
            let
                queryModel =
                    model.query
            in
            ( { model | response = Loading }, searchRequest ReceivedSearchResponse queryModel )

        OnWindowResize device ->
            ( { model | viewingDevice = device }, Cmd.none )

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


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage

        initialQuery =
            SearchQueryArgs "*:*" [] ""

        initialErrorMessage =
            ""

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight
    in
    ( Model language initialQuery NoResponseToShow initialErrorMessage initialDevice, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize <|
            \width height -> OnWindowResize (detectDevice width height)
        ]


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
