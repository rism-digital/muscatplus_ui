module Subscriptions exposing (subscriptions)

import Browser.Events exposing (onKeyUp, onResize)
import Device exposing (detectDevice)
import Json.Decode as Decode
import Json.Encode as Encode
import KeyCodes exposing (ArrowDirection(..), keyDecoder)
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.Search.Msg as SearchMsg
import Page.SideBar.Msg as SideBarMsg
import Ports.Incoming exposing (IncomingMessage(..), decodeIncomingMessage, receiveIncomingMessageFromPort)


{-|

    Listens for incoming messages

-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize (\width height -> Msg.UserResizedWindow (detectDevice width height))
        , receiveIncomingMessageFromPort (messageReceiverHelper model)
        , handleKeyboardNavigation model
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
                    SearchMsg.UserPressedAnArrowKey subm
                        |> Msg.UserInteractedWithSearchPage
        )
        (onKeyUp keyDecoder)
