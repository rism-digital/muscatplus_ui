port module Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)

import Json.Encode as Encode
import Language exposing (Language, parseLanguageToLocale)
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))
import WebAudio


port sendOutgoingMessageOnPort : Encode.Value -> Cmd msg


type OutgoingMessage
    = PortSendSaveLanguagePreference Language
    | PortSendSetNationalCollectionSelection (Maybe String)
    | PortSendSaveSearchPreference { key : String, value : SearchPreferenceVariant }
    | PortSendHeaderMetaInfo { description : String }
    | PortSendKeyboardAudioNote (List WebAudio.Node)
    | PortSendEnableMuscatLinks Bool


convertOutgoingMessageToJsonMsg : OutgoingMessage -> List ( String, Encode.Value )
convertOutgoingMessageToJsonMsg msg =
    case msg of
        PortSendSaveLanguagePreference lang ->
            [ ( "msg", Encode.string "save-language-preference" )
            , ( "value", Encode.string (parseLanguageToLocale lang) )
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
                        ListPreference listPref ->
                            Encode.list (\a -> Encode.string a) listPref

                        BoolPreference boolPref ->
                            Encode.bool boolPref
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

        PortSendKeyboardAudioNote audioGraph ->
            [ ( "msg", Encode.string "generate-piano-keyboard-note" )
            , ( "value", Encode.list WebAudio.encode audioGraph )
            ]

        PortSendEnableMuscatLinks isEnabled ->
            [ ( "msg", Encode.string "enable-muscat-links" )
            , ( "value", Encode.bool isEnabled )
            ]


encodeMessageForPortSend : OutgoingMessage -> Encode.Value
encodeMessageForPortSend msg =
    convertOutgoingMessageToJsonMsg msg
        |> Encode.object
