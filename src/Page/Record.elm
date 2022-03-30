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
    , searchResults = NoResponseToShow
    , activeSearch = ActiveSearch.init route
    , preview = NoResponseToShow
    , selectedResult = Nothing
    }


recordPageRequest : Url -> Cmd RecordMsg
recordPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithRecordData (Url.toString initialUrl)


recordSearchRequest : String -> Cmd RecordMsg
recordSearchRequest searchUrl =
    createRequestWithDecoder ServerRespondedWithPageSearch searchUrl


update : Session -> RecordMsg -> RecordPageModel -> ( RecordPageModel, Cmd RecordMsg )
update session msg model =
    case msg of
        ServerRespondedWithRecordData (Ok ( _, response )) ->
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

        ServerRespondedWithPageSearch (Ok ( _, response )) ->
            ( { model | searchResults = Response response }, Cmd.none )

        ServerRespondedWithPageSearch (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        UserClickedRecordViewTab recordTab ->
            let
                cmd =
                    case recordTab of
                        DefaultRecordViewTab ->
                            Cmd.none

                        RelatedSourcesSearchTab searchUrl ->
                            case model.searchResults of
                                -- if there is already a response, then don't refresh it when we switch tabs
                                Response _ ->
                                    Cmd.none

                                _ ->
                                    recordSearchRequest searchUrl
            in
            ( { model
                | currentTab = recordTab
              }
            , cmd
            )

        UserClickedSearchResultsPagination pageUrl ->
            ( model, Cmd.none )

        UserClickedSearchResultForPreview sourceId ->
            ( model, Cmd.none )

        UserClickedToCItem idParam ->
            ( model
            , jumpToId NothingHappened idParam
            )

        NothingHappened ->
            ( model, Cmd.none )
