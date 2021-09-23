module Page.UI.Keyboard.Msg exposing (..)

import Http
import Page.UI.Keyboard.Model exposing (KeyNoteName, Octave)


type KeyboardMsg
    = UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardDeleteNote
    | UserClickedPianoKeyboardChangeClef
    | UserClickedPianoKeyboardChangeTimeSignature
    | UserClickedPianoKeyboardChangeKeySignature
    | UserClickedPianoKeyboardSearchSubmit
    | ServerRespondedWithRenderedNotation (Result Http.Error String)
    | ClientRequestedRenderedNotation
    | NothingHappenedWithTheKeyboard
