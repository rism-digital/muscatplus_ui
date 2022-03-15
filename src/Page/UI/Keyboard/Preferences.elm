module Page.UI.Keyboard.Preferences exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Page.UI.Keyboard.Model exposing (KeyboardInputMode(..))


defaultKeyboardPreferences : KeyboardPreferences
defaultKeyboardPreferences =
    { inputMode = PianoInput }


encodeInputMode : KeyboardInputMode -> Encode.Value
encodeInputMode inputMode =
    case inputMode of
        PianoInput ->
            Encode.string "piano-input"

        FormInput ->
            Encode.string "form-input"


inputModeDecoder : Decoder KeyboardInputMode
inputModeDecoder =
    Decode.string
        |> Decode.andThen
            (\inputMode ->
                if inputMode == "form-input" then
                    Decode.succeed FormInput

                else
                    Decode.succeed PianoInput
            )


type alias KeyboardPreferences =
    { inputMode : KeyboardInputMode }


keyboardPreferencesDecoder : Decoder KeyboardPreferences
keyboardPreferencesDecoder =
    Decode.succeed KeyboardPreferences
        |> required "input-mode" inputModeDecoder


encodeKeyboardPreferences : KeyboardPreferences -> Encode.Value
encodeKeyboardPreferences keyboardPrefs =
    Encode.object [ ( "input-mode", encodeInputMode keyboardPrefs.inputMode ) ]
