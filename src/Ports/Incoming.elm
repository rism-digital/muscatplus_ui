port module Ports.Incoming exposing (..)

import Json.Decode as Decode exposing (Decoder, string)


type IncomingMessage
    = PortReceiveTriggerSearch Decode.Value
    | PortReceivedUnknownMessage


decodeIncomingMessage : Decoder IncomingMessage
decodeIncomingMessage =
    Decode.field "msg" string
        |> Decode.andThen convertMsgStringToIncomingMessage


convertMsgStringToIncomingMessage : String -> Decoder IncomingMessage
convertMsgStringToIncomingMessage msgString =
    case msgString of
        "trigger-search" ->
            Decode.map (\r -> PortReceiveTriggerSearch r) Decode.value

        _ ->
            Decode.succeed PortReceivedUnknownMessage


port receiveIncomingMessageFromPort : (Decode.Value -> msg) -> Sub msg
