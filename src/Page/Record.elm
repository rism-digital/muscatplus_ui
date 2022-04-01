module Page.Record exposing (..)

import ActiveSearch
import Browser.Navigation as Nav
import Config as C
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Page.Route exposing (Route(..))
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)
import Utlities exposing (convertNodeIdToPath, convertPathToNodeId)
import Viewport exposing (jumpToId)


type alias Model =
    RecordPageModel


type alias Msg =
    RecordMsg


init : Url -> Route -> RecordPageModel
init incomingUrl route =
    let
        selectedResult =
            incomingUrl.fragment
                |> Maybe.andThen (\f -> Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f))

        tabView =
            case route of
                InstitutionSourcePageRoute _ _ ->
                    RelatedSourcesSearchTab <| Url.toString incomingUrl

                _ ->
                    DefaultRecordViewTab <| Url.toString incomingUrl
    in
    { response = Loading Nothing
    , currentTab = tabView
    , searchResults = NoResponseToShow
    , activeSearch = ActiveSearch.init route
    , preview = NoResponseToShow
    , selectedResult = selectedResult
    }


load : Url -> Route -> RecordPageModel -> RecordPageModel
load url route oldModel =
    let
        ( previewResp, selectedResult ) =
            case url.fragment of
                Just f ->
                    ( oldModel.preview, Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f) )

                Nothing ->
                    ( NoResponseToShow, Nothing )

        tabView =
            case route of
                InstitutionSourcePageRoute _ _ ->
                    RelatedSourcesSearchTab <| Url.toString url

                _ ->
                    DefaultRecordViewTab <| Url.toString url
    in
    { response = oldModel.response
    , activeSearch = oldModel.activeSearch
    , preview = previewResp
    , selectedResult = selectedResult
    , currentTab = tabView
    , searchResults = oldModel.searchResults
    }


recordPageRequest : Url -> Cmd RecordMsg
recordPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithRecordData (Url.toString initialUrl)


recordSearchRequest : Url -> Cmd RecordMsg
recordSearchRequest searchUrl =
    createRequestWithDecoder ServerRespondedWithPageSearch (Url.toString searchUrl)


requestPreviewIfSelected : Maybe String -> Cmd RecordMsg
requestPreviewIfSelected selected =
    case selected of
        Just s ->
            recordPagePreviewRequest s

        Nothing ->
            Cmd.none


recordPagePreviewRequest : String -> Cmd RecordMsg
recordPagePreviewRequest previewUrl =
    createRequestWithDecoder ServerRespondedWithRecordPreview previewUrl


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
            ( { model
                | searchResults = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithPageSearch (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        ServerRespondedWithRecordPreview (Ok ( _, response )) ->
            ( { model
                | preview = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithRecordPreview (Err error) ->
            ( { model
                | preview = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        UserClickedRecordViewTab recordTab ->
            let
                cmd =
                    case recordTab of
                        DefaultRecordViewTab recordUrl ->
                            Nav.pushUrl session.key recordUrl

                        RelatedSourcesSearchTab searchUrl ->
                            case model.searchResults of
                                -- if there is already a response, then don't refresh it when we switch tabs
                                Response _ ->
                                    Nav.pushUrl session.key searchUrl

                                _ ->
                                    let
                                        searchRequest =
                                            Url.fromString searchUrl
                                                |> Maybe.andThen (\a -> Just <| recordSearchRequest a)
                                                |> Maybe.withDefault Cmd.none
                                    in
                                    Cmd.batch
                                        [ searchRequest
                                        , Nav.pushUrl session.key searchUrl
                                        ]
            in
            ( { model
                | currentTab = recordTab
              }
            , cmd
            )

        UserClickedSearchResultsPagination pageUrl ->
            ( model, Cmd.none )

        UserClickedSearchResultForPreview result ->
            let
                resultUrl =
                    Url.fromString result

                resPath =
                    case resultUrl of
                        Just p ->
                            String.dropLeft 1 p.path
                                |> convertPathToNodeId
                                |> Just

                        Nothing ->
                            Nothing

                currentUrl =
                    session.url

                newUrl =
                    { currentUrl | fragment = resPath }

                newUrlStr =
                    Url.toString newUrl
            in
            ( { model
                | selectedResult = Just result
              }
            , Nav.pushUrl session.key newUrlStr
            )

        UserClickedClosePreviewWindow ->
            let
                currentUrl =
                    session.url

                newUrl =
                    { currentUrl | fragment = Nothing }

                newUrlStr =
                    Url.toString newUrl
            in
            ( { model
                | preview = NoResponseToShow
                , selectedResult = Nothing
              }
            , Nav.pushUrl session.key newUrlStr
            )

        UserClickedToCItem idParam ->
            ( model
            , jumpToId NothingHappened idParam
            )

        NothingHappened ->
            ( model, Cmd.none )
