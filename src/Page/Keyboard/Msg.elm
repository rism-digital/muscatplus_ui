module Page.Keyboard.Msg exposing (..)

import Http
import Http.Detailed
import Page.Keyboard.Model exposing (Clef, KeyNoteName, Octave)


type KeyboardMsg
    = ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | ClientRequestedRenderedNotation
    | UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardDeleteNote
    | UserClickedPianoKeyboardChangeClef Clef
    | UserEnteredPAEText String
    | UserClickedPianoKeyboardChangeTimeSignature
    | UserClickedPianoKeyboardChangeKeySignature
    | UserClickedPianoKeyboardSearchSubmit
    | NothingHappenedWithTheKeyboard
