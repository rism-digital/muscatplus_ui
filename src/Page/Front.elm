module Page.Front exposing (..)

import ActiveSearch exposing (setActiveSearch)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg(..))
import Page.Query exposing (setKeywordQuery, setNextQuery, toNextQuery)
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Response exposing (Response(..))
import Url exposing (Url)
import Utlities exposing (flip)


type alias Model =
    FrontPageModel


type alias Msg =
    FrontMsg


init : FrontPageModel
init =
    { response = Loading Nothing
    , activeSearch = ActiveSearch.empty
    }


frontPageRequest : Url -> Cmd FrontMsg
frontPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithFrontData (Url.toString initialUrl)


update : FrontMsg -> FrontPageModel -> ( FrontPageModel, Cmd FrontMsg )
update msg model =
    case msg of
        ServerRespondedWithFrontData (Ok ( _, response )) ->
            ( { model
                | response = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithFrontData (Err err) ->
            ( { model
                | response = Error (createErrorMessage err)
              }
            , Cmd.none
            )

        UserInputTextInKeywordQueryBox queryText ->
            let
                newText =
                    if String.isEmpty queryText then
                        Nothing

                    else
                        Just queryText

                newQueryArgs =
                    toNextQuery model.activeSearch
                        |> setKeywordQuery newText

                newModel =
                    setNextQuery newQueryArgs model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel, Cmd.none )

        UserTriggeredSearchSubmit ->
            ( model, Cmd.none )

        NothingHappened ->
            ( model, Cmd.none )
