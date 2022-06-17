port module Ports.Outgoing exposing (OutgoingMessage(..), convertOutgoingMessageToJsonMsg, encodeMessageForPortSend, sendOutgoingMessageOnPort)

import Json.Encode as Encode
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))


port sendOutgoingMessageOnPort : Encode.Value -> Cmd msg


type OutgoingMessage
    = PortSendSaveLanguagePreference String
    | PortSendSetNationalCollectionSelection (Maybe String)
    | PortSendSaveSearchPreference { key : String, value : SearchPreferenceVariant }
    | PortSendHeaderMetaInfo { description : String }
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

        PortSendSaveSearchPreference pref ->
            let
                prefValue =
                    case pref.value of
                        StringPreference stringPref ->
                            Encode.string stringPref

                        ListPreference listPref ->
                            Encode.list (\a -> Encode.string a) listPref
            in
            [ ( "msg", Encode.string "save-search-preference" )
            , ( "value"
              , Encode.object
                    [ ( "key", Encode.string pref.key )
                    , ( "value", prefValue )
                    ]
              )
            ]

        PortSendHeaderMetaInfo metaInfo ->
            [ ( "msg", Encode.string "set-meta-info" )
            , ( "value"
              , Encode.object
                    [ ( "description", Encode.string metaInfo.description ) ]
              )
            ]

        PortSendUnknownMessage ->
            [ ( "msg", Encode.string "unknown-message" )
            , ( "value", Encode.null )
            ]


encodeMessageForPortSend : OutgoingMessage -> Encode.Value
encodeMessageForPortSend msg =
    convertOutgoingMessageToJsonMsg msg
        |> Encode.object
