module Page.Record exposing (..)

import ActiveSearch
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Page.Route exposing (Route)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)
import Viewport exposing (jumpToId)


type alias Model =
    RecordPageModel


type alias Msg =
    RecordMsg


init : Route -> RecordPageModel
init route =
    { response = Loading Nothing
    , currentTab = DefaultRecordViewTab
    , searchResults = Loading Nothing
    , activeSearch = ActiveSearch.init route
    }


recordPageRequest : Url -> Cmd RecordMsg
recordPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithRecordData (Url.toString initialUrl)


update : Session -> RecordMsg -> RecordPageModel -> ( RecordPageModel, Cmd RecordMsg )
update session msg model =
    case msg of
        ServerRespondedWithRecordData (Ok ( metadata, response )) ->
            ( { model
                | response = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithRecordData (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        ServerRespondedWithPageSearch (Ok ( metadata, response )) ->
            ( model, Cmd.none )

        ServerRespondedWithPageSearch (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        UserClickedRecordViewTab recordTab ->
            ( model, Cmd.none )

        UserClickedRecordViewTabPagination url ->
            ( model, Cmd.none )

        UserClickedToCItem idParam ->
            ( model
            , jumpToId NothingHappened idParam
            )

        UserInputTextInPageQueryBox query ->
            ( model, Cmd.none )

        UserClickedPageSearchSubmitButton ->
            ( model, Cmd.none )

        NothingHappened ->
            ( model, Cmd.none )
