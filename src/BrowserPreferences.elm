module BrowserPreferences exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Page.UI.Keyboard.Preferences exposing (KeyboardPreferences, defaultKeyboardPreferences, encodeKeyboardPreferences, keyboardPreferencesDecoder)


type alias BrowserPreferences =
    { keyboard : KeyboardPreferences
    , collapsedFacetSections : List String
    }


defaultPreferences : BrowserPreferences
defaultPreferences =
    { keyboard = defaultKeyboardPreferences
    , collapsedFacetSections = []
    }


browserPreferencesDecoder : Decoder BrowserPreferences
browserPreferencesDecoder =
    Decode.succeed BrowserPreferences
        |> required "keyboard" keyboardPreferencesDecoder
        |> required "collapsedFacetSections" (list string)


encodeBrowserPreferences : BrowserPreferences -> Encode.Value
encodeBrowserPreferences prefs =
    Encode.object
        [ ( "keyboard", encodeKeyboardPreferences prefs.keyboard )
        , ( "collapsedFacetSections", Encode.list (\a -> Encode.string a) prefs.collapsedFacetSections )
        ]
