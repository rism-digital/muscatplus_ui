module Page.UI.Keyboard.Msg exposing (..)

import Http
import Http.Detailed
import Page.UI.Keyboard.Model exposing (KeyNoteName, Octave)


type KeyboardMsg
    = ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardDeleteNote
    | UserClickedPianoKeyboardChangeClef
    | UserClickedPianoKeyboardChangeTimeSignature
    | UserClickedPianoKeyboardChangeKeySignature
    | UserClickedPianoKeyboardSearchSubmit
    | ClientRequestedRenderedNotation
    | NothingHappenedWithTheKeyboard
