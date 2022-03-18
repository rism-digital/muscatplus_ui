module Page.Keyboard.Msg exposing (..)

import Http
import Http.Detailed
import Page.Keyboard.Model exposing (Clef, KeyNoteName, Octave, QueryMode)
import Page.RecordTypes.Incipit exposing (IncipitValidationBody)


type KeyboardMsg
    = ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | ServerRespondedWithNotationValidation (Result (Http.Detailed.Error String) ( Http.Metadata, IncipitValidationBody ))
    | ClientRequestedRenderedNotation
    | UserClickedPianoKeyboardKey KeyNoteName Octave
    | UserClickedPianoKeyboardChangeClef Clef
    | UserInteractedWithPAEText String
    | UserRequestedProbeUpdate
    | UserClickedPianoKeyboardChangeTimeSignature
    | UserClickedPianoKeyboardChangeKeySignature
    | UserClickedPianoKeyboardSearchSubmit
    | UserChangedQueryMode QueryMode
    | NothingHappenedWithTheKeyboard
