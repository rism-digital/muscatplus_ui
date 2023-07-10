port module Ports.Incoming exposing (IncomingMessage(..), decodeIncomingMessage, receiveIncomingMessageFromPort)

import Json.Decode as Decode exposing (Decoder, string)
import SearchPreferences exposing (SearchPreferences, searchPreferencesDecoder)


port receiveIncomingMessageFromPort : (Decode.Value -> msg) -> Sub msg


type IncomingMessage
    = PortReceiveTriggerSearch
    | PortReceiveSearchPreferences SearchPreferences
    | PortReceiveMuscatLinksSet Bool
    | PortReceivedUnknownMessage


convertMsgStringToIncomingMessage : String -> Decoder IncomingMessage
convertMsgStringToIncomingMessage msgString =
    case msgString of
        "muscat-links-set" ->
            Decode.map (\v -> PortReceiveMuscatLinksSet v) Decode.bool

        "search-preferences-set" ->
            Decode.field "value" searchPreferencesDecoder
                |> Decode.map (\values -> PortReceiveSearchPreferences values)

        "trigger-search" ->
            Decode.map (\_ -> PortReceiveTriggerSearch) Decode.value

        _ ->
            Decode.succeed PortReceivedUnknownMessage


decodeIncomingMessage : Decoder IncomingMessage
decodeIncomingMessage =
    Decode.field "msg" string
        |> Decode.andThen convertMsgStringToIncomingMessage
