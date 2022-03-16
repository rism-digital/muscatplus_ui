module SearchPreferences exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant)


type alias SearchPreferences =
    { keyboardInputMode : String
    , collapsedFacetSections : List String
    }


defaultPreferences : SearchPreferences
defaultPreferences =
    { keyboardInputMode = ""
    , collapsedFacetSections = []
    }


searchPreferencesDecoder : Decoder SearchPreferences
searchPreferencesDecoder =
    Decode.succeed SearchPreferences
        |> required "keyboardInputMode" string
        |> required "collapsedFacetSections" (list string)


encodeSearchPreferences : SearchPreferences -> Encode.Value
encodeSearchPreferences prefs =
    Encode.object
        [ ( "keyboardInputMode", Encode.string prefs.keyboardInputMode )
        , ( "collapsedFacetSections", Encode.list (\a -> Encode.string a) prefs.collapsedFacetSections )
        ]


saveSearchPreference : { key : String, value : SearchPreferenceVariant } -> Cmd msg
saveSearchPreference pref =
    encodeMessageForPortSend (PortSendSaveSearchPreference pref)
        |> sendOutgoingMessageOnPort
