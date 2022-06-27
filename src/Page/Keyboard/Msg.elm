module Page.Keyboard.Msg exposing (KeyboardMsg(..))

import Debouncer.Messages as Debouncer
import Http
import Http.Detailed
import Page.Keyboard.Model exposing (Clef, KeyNoteName, KeySignature, Octave, QueryMode, TimeSignature)


type KeyboardMsg
    = ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardChangeClef Clef
    | UserInteractedWithPAEText String
    | DebouncerCapturedPAEText (Debouncer.Msg KeyboardMsg)
    | DebouncerSettledToSendPAEText
    | UserClickedPianoKeyboardChangeTimeSignature TimeSignature
    | UserClickedPianoKeyboardChangeKeySignature KeySignature
    | UserChangedQueryMode QueryMode
    | NothingHappenedWithTheKeyboard
