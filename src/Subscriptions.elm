module Subscriptions exposing (subscriptions)

import Browser.Events exposing (onKeyUp, onMouseMove, onMouseUp, onResize)
import Device exposing (detectDevice)
import Json.Decode as Decode
import Json.Encode as Encode
import KeyCodes exposing (ArrowDirection(..), keyDecoder)
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.Record.Msg as RecordMsg
import Page.Search.Msg as SearchMsg
import Page.SideBar.Msg as SideBarMsg
import Ports.Incoming exposing (IncomingMessage(..), decodeIncomingMessage, receiveIncomingMessageFromPort)


{-|

    Listens for incoming messages

-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize (\width height -> Msg.UserResizedWindow (detectDevice width height) width height)
        , receiveIncomingMessageFromPort (messageReceiverHelper model)
        , handleKeyboardNavigation model
        , handleSearchResultsResize model
        ]


{-|

    When a user sets their national collection, it makes sense to refresh
    their search results, if they are on the search page. This helper listens
    for an incoming message from the JS Port, and then if the current page
    is the search page, will trigger a 'search submit'. This will then apply
    the `nc` filter to the search results, and limit it to only results from
    that national collection.

-}
handleIncomingSearchTrigger : Model -> Msg
handleIncomingSearchTrigger model =
    case model of
        SearchPage _ _ ->
            Msg.UserInteractedWithSearchPage SearchMsg.UserTriggeredSearchSubmit

        _ ->
            Msg.NothingHappened


{-|

    Convert incoming message types to the central Msg type.

-}
messageReceiverHelper : Model -> Encode.Value -> Msg
messageReceiverHelper model val =
    case Decode.decodeValue decodeIncomingMessage val of
        Ok v ->
            case v of
                PortReceiveTriggerSearch ->
                    handleIncomingSearchTrigger model

                PortReceiveSearchPreferences values ->
                    SideBarMsg.ClientSetSearchPreferencesThroughPort values
                        |> Msg.UserInteractedWithSideBar

                PortReceiveMuscatLinksSet newValue ->
                    SideBarMsg.ClientUpdatedMuscatLinks newValue
                        |> Msg.UserInteractedWithSideBar

                PortReceivedUnknownMessage ->
                    Msg.NothingHappened

        Err e ->
            Msg.ClientReceivedABadPortMessage (Decode.errorToString e)


handleKeyboardNavigation : Model -> Sub Msg
handleKeyboardNavigation model =
    Sub.map
        (\subm ->
            case subm of
                NotAnArrowKey ->
                    Msg.UserInteractedWithSearchPage SearchMsg.NothingHappened

                _ ->
                    case model of
                        SearchPage _ _ ->
                            SearchMsg.UserPressedAnArrowKey subm
                                |> Msg.UserInteractedWithSearchPage

                        SourcePage _ _ ->
                            RecordMsg.UserPressedAnArrowKey subm
                                |> Msg.UserInteractedWithRecordPage

                        PersonPage _ _ ->
                            RecordMsg.UserPressedAnArrowKey subm
                                |> Msg.UserInteractedWithRecordPage

                        InstitutionPage _ _ ->
                            RecordMsg.UserPressedAnArrowKey subm
                                |> Msg.UserInteractedWithRecordPage

                        _ ->
                            Msg.NothingHappened
        )
        (onKeyUp keyDecoder)


handleSearchResultsResize : Model -> Sub Msg
handleSearchResultsResize model =
    if searchResultsResizeIsActive model then
        Sub.batch
            [ onMouseMove (Decode.map (routeSearchResultsResizeMove model) (Decode.field "clientX" Decode.int))
            , onMouseUp (Decode.succeed (routeSearchResultsResizeStop model))
            ]

    else
        Sub.none


searchResultsResizeIsActive : Model -> Bool
searchResultsResizeIsActive model =
    case model of
        SearchPage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        SourcePage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        PersonPage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        HoldingPage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        InstitutionPage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        PublicationPage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        PublicationListPage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        WorkPage _ pageModel ->
            pageModel.resultsPanelResize /= Nothing

        _ ->
            False


routeSearchResultsResizeMove : Model -> Int -> Msg
routeSearchResultsResizeMove model clientX =
    case model of
        SearchPage _ _ ->
            Msg.UserInteractedWithSearchPage (SearchMsg.ClientMovedSearchResultsResize clientX)

        SourcePage _ _ ->
            Msg.UserInteractedWithRecordPage (RecordMsg.ClientMovedSearchResultsResize clientX)

        PersonPage _ _ ->
            Msg.UserInteractedWithRecordPage (RecordMsg.ClientMovedSearchResultsResize clientX)

        HoldingPage _ _ ->
            Msg.UserInteractedWithRecordPage (RecordMsg.ClientMovedSearchResultsResize clientX)

        InstitutionPage _ _ ->
            Msg.UserInteractedWithRecordPage (RecordMsg.ClientMovedSearchResultsResize clientX)

        PublicationPage _ _ ->
            Msg.UserInteractedWithRecordPage (RecordMsg.ClientMovedSearchResultsResize clientX)

        PublicationListPage _ _ ->
            Msg.UserInteractedWithRecordPage (RecordMsg.ClientMovedSearchResultsResize clientX)

        WorkPage _ _ ->
            Msg.UserInteractedWithRecordPage (RecordMsg.ClientMovedSearchResultsResize clientX)

        _ ->
            Msg.NothingHappened


routeSearchResultsResizeStop : Model -> Msg
routeSearchResultsResizeStop model =
    case model of
        SearchPage _ _ ->
            Msg.UserInteractedWithSearchPage SearchMsg.ClientStoppedSearchResultsResize

        SourcePage _ _ ->
            Msg.UserInteractedWithRecordPage RecordMsg.ClientStoppedSearchResultsResize

        PersonPage _ _ ->
            Msg.UserInteractedWithRecordPage RecordMsg.ClientStoppedSearchResultsResize

        HoldingPage _ _ ->
            Msg.UserInteractedWithRecordPage RecordMsg.ClientStoppedSearchResultsResize

        InstitutionPage _ _ ->
            Msg.UserInteractedWithRecordPage RecordMsg.ClientStoppedSearchResultsResize

        PublicationPage _ _ ->
            Msg.UserInteractedWithRecordPage RecordMsg.ClientStoppedSearchResultsResize

        PublicationListPage _ _ ->
            Msg.UserInteractedWithRecordPage RecordMsg.ClientStoppedSearchResultsResize

        WorkPage _ _ ->
            Msg.UserInteractedWithRecordPage RecordMsg.ClientStoppedSearchResultsResize

        _ ->
            Msg.NothingHappened
