module Page.Keyboard.Msg exposing (..)

import Debouncer.Messages as Debouncer
import Http
import Http.Detailed
import Page.Keyboard.Model exposing (Clef, KeyNoteName, KeySignature, Octave, QueryMode, TimeSignature)
import Page.RecordTypes.Incipit exposing (IncipitValidationBody)


type KeyboardMsg
    = ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | ServerRespondedWithNotationValidation (Result (Http.Detailed.Error String) ( Http.Metadata, IncipitValidationBody ))
    | ClientRequestedRenderedNotation
    | UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardChangeClef Clef
    | UserInteractedWithPAEText String
    | DebouncerCapturedPAEText (Debouncer.Msg KeyboardMsg)
    | DebouncerSettledToSendPAEText
    | UserRequestedProbeUpdate
    | UserClickedPianoKeyboardChangeTimeSignature TimeSignature
    | UserClickedPianoKeyboardChangeKeySignature KeySignature
    | UserChangedQueryMode QueryMode
    | NothingHappenedWithTheKeyboard
