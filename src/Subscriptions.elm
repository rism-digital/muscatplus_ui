module Subscriptions exposing (subscriptions)

import Browser.Events exposing (onResize)
import Device exposing (detectDevice)
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.Search.Msg as SearchMsg
import Ports.Incoming exposing (IncomingMessage(..), decodeIncomingMessage, receiveIncomingMessageFromPort)


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
                PortReceiveTriggerSearch _ ->
                    handleIncomingSearchTrigger model

                PortReceiveTriggerBrowserSave _ ->
                    Msg.ClientRequestedBrowserPreferencesSave

                PortReceivedUnknownMessage ->
                    Msg.NothingHappened

        Err e ->
            Msg.ClientReceivedABadPortMessage <| Decode.errorToString e


{-|

    Listens for incoming messages

-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize <| \width height -> Msg.UserResizedWindow (detectDevice width height)
        , receiveIncomingMessageFromPort <| messageReceiverHelper model
        ]
