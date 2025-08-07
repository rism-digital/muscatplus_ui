module Page.Error exposing (Model, Msg, init, initialCmd, update)

import Http.Detailed exposing (Error(..))
import Language.LocalTranslations exposing (errorMessages)
import Page.Error.Model exposing (ErrorPageModel)
import Page.Error.Msg exposing (NotFoundMsg(..))
import Page.Request exposing (createRequestWithNotFoundDecoder)
import Page.UI.Errors exposing (ErrorResponse(..), createErrorMessage)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)


type alias Model =
    ErrorPageModel


type alias Msg =
    NotFoundMsg


init : ErrorPageModel
init =
    { response = NoResponseToShow }


initialCmd : Url -> Cmd NotFoundMsg
initialCmd initialUrl =
    createRequestWithNotFoundDecoder ServerRespondedWithNotFoundData (Url.toString initialUrl)


update : Session -> NotFoundMsg -> ErrorPageModel -> ( ErrorPageModel, Cmd NotFoundMsg )
update _ msg model =
    case msg of
        ServerRespondedWithNotFoundData (Ok resp) ->
            ( { model
                | response =
                    Error
                        (NotFoundResponse
                            { label = errorMessages.notFound
                            , errorMessage = Tuple.second resp
                            }
                        )
              }
            , Cmd.none
            )

        ServerRespondedWithNotFoundData (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )
