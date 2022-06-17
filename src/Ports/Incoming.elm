port module Ports.Incoming exposing (IncomingMessage(..), convertMsgStringToIncomingMessage, decodeIncomingMessage, receiveIncomingMessageFromPort)

import Json.Decode as Decode exposing (Decoder, string)


port receiveIncomingMessageFromPort : (Decode.Value -> msg) -> Sub msg


type IncomingMessage
    = PortReceiveTriggerSearch
    | PortReceivedUnknownMessage


convertMsgStringToIncomingMessage : String -> Decoder IncomingMessage
convertMsgStringToIncomingMessage msgString =
    case msgString of
        "trigger-search" ->
            Decode.map (\r -> PortReceiveTriggerSearch) Decode.value

        _ ->
            Decode.succeed PortReceivedUnknownMessage


decodeIncomingMessage : Decoder IncomingMessage
decodeIncomingMessage =
    Decode.field "msg" string
        |> Decode.andThen convertMsgStringToIncomingMessage
