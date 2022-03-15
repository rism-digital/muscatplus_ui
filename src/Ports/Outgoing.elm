port module Ports.Outgoing exposing (..)

import Json.Encode as Encode


type OutgoingMessage
    = PortSendSaveLanguagePreference String
    | PortSendSetNationalCollectionSelection (Maybe String)
    | PortSendSaveBrowserPreferences
    | PortSendUnknownMessage


convertOutgoingMessageToJsonMsg : OutgoingMessage -> List ( String, Encode.Value )
convertOutgoingMessageToJsonMsg msg =
    case msg of
        PortSendSaveLanguagePreference lang ->
            [ ( "msg", Encode.string "save-language-preference" )
            , ( "value", Encode.string lang )
            ]

        PortSendSetNationalCollectionSelection nationalCollection ->
            let
                encodedCollection =
                    case nationalCollection of
                        Just countryCode ->
                            Encode.string countryCode

                        Nothing ->
                            Encode.null
            in
            [ ( "msg", Encode.string "set-national-collection-selection" )
            , ( "value", encodedCollection )
            ]

        PortSendSaveBrowserPreferences ->
            [ ( "msg", Encode.string "save-browser-preferences" )
            , ( "value", Encode.null )
            ]

        PortSendUnknownMessage ->
            [ ( "msg", Encode.string "unknown-message" )
            , ( "value", Encode.null )
            ]


encodeMessageForPortSend : OutgoingMessage -> Encode.Value
encodeMessageForPortSend msg =
    convertOutgoingMessageToJsonMsg msg
        |> Encode.object


port sendOutgoingMessageOnPort : Encode.Value -> Cmd msg
