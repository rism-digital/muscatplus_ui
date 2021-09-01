module Page.UI.Keyboard.Msg exposing (..)

import Http
import Page.UI.Keyboard.Model exposing (KeyNoteName, Octave)


type KeyboardMsg
    = UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardDeleteNote
    | UserClickedPianoKeyboardChangeClef
    | UserClickedPianoKeyboardChangeTimeSignature
    | UserClickedPianoKeyboardChangeKeySignature
    | ServerRespondedWithRenderedNotation (Result Http.Error String)
