module SearchApp exposing (..)

import Api.Search exposing (ApiResponse(..), SearchQueryArgs, searchRequest)
import Browser
import Config
import Http exposing (Error(..))
import Language exposing (Language, parseLocaleToLanguage)
import Search.DataTypes exposing (Model, Msg(..))
import Search.Views exposing (renderBody)


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

        SearchInput input ->
            if String.length model.keywordQuery > Config.minimumQueryLength then
                let
                    q =
                        SearchQueryArgs input [] ""
                in
                ( { model | keywordQuery = input }, Cmd.none )

            else if String.length input == 0 then
                ( { model | keywordQuery = input }, Cmd.none )

            else
                ( { model | keywordQuery = input }, Cmd.none )

        SearchSubmit ->
            let
                q =
                    SearchQueryArgs model.keywordQuery [] ""
            in
            ( { model | response = Loading }, searchRequest ReceivedSearchResponse q )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "RISM Online"
    , body =
        renderBody model
    }


type alias Flags =
    { locale : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage

        initialQuery =
            ""

        initialErrorMessage =
            ""
    in
    ( Model language initialQuery NoResponseToShow initialErrorMessage, Cmd.none )


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
