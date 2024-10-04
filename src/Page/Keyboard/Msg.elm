module Page.Keyboard.Msg exposing (KeyboardMsg(..))

import Debouncer.Messages as Debouncer
import Http
import Http.Detailed
import Page.Keyboard.Model exposing (Clef, KeySignature, KeyboardKeyPress, QueryMode, TimeSignature)


type KeyboardMsg
    = ServerRespondedWithRenderedNotation (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | DebouncerCapturedPAEText (Debouncer.Msg KeyboardMsg)
    | DebouncerSettledToSendPAEText
    | UserClickedPianoKeyboardKeyOn KeyboardKeyPress
    | UserClickedPianoKeyboardKeyOff KeyboardKeyPress
    | UserToggledAudioMuted Bool
    | UserInteractedWithPAEText String
    | UserChangedQueryMode QueryMode
    | UserClickedPianoKeyboardChangeClef Clef
    | UserClickedPianoKeyboardChangeTimeSignature TimeSignature
    | UserClickedPianoKeyboardChangeKeySignature KeySignature
    | UserToggledPAEHelpText
