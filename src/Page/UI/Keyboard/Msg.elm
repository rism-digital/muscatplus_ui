module Page.UI.Keyboard.Msg exposing (..)

import Http
import Http.Detailed
import Page.UI.Keyboard.Model exposing (KeyNoteName, Octave)


type KeyboardMsg
    = UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardDeleteNote
    | UserClickedPianoKeyboardChangeClef
    | UserClickedPianoKeyboardChangeTimeSignature
    | UserClickedPianoKeyboardChangeKeySignature
    | UserClickedPianoKeyboardSearchSubmit
    | UserClickedClearAllNotes
    | ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | ClientRequestedRenderedNotation
    | NothingHappenedWithTheKeyboard
