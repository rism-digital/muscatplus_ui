module Page.UI.Keyboard.Msg exposing (..)

import Http
import Http.Detailed
import Page.UI.Keyboard.Model exposing (Clef, KeyNoteName, KeyboardInputMode, Octave)


type KeyboardMsg
    = ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | ClientRequestedRenderedNotation
    | UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardDeleteNote
    | UserToggledInputMode KeyboardInputMode
    | UserClickedPianoKeyboardChangeClef Clef
    | UserEnteredPAEText String
    | UserClickedPianoKeyboardChangeTimeSignature
    | UserClickedPianoKeyboardChangeKeySignature
    | UserClickedPianoKeyboardSearchSubmit
    | NothingHappenedWithTheKeyboard
