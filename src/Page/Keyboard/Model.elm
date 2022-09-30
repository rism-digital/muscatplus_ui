module Page.Keyboard.Model exposing
    ( Clef(..)
    , KeyNoteName(..)
    , KeySignature(..)
    , KeyboardKeyPress(..)
    , KeyboardModel
    , KeyboardQuery
    , Octave
    , Octaves
    , QueryMode(..)
    , TimeSignature(..)
    , setClef
    , setKeySignature
    , setKeyboardQuery
    , setNoteData
    , setQueryMode
    , setTimeSignature
    , toKeyboardQuery
    )

import Debouncer.Messages exposing (Debouncer)


{-|

    "M" indicates a mensural clef

-}
type Clef
    = C1
    | C2
    | C3
    | C4
    | F3
    | F4
    | G1
    | G2
    | G2Oct
    | G3
    | C1M
    | C2M
    | C3M
    | F3M
    | F4M
    | G2M
    | G3M


type KeyNoteName
    = KC
    | KCn
    | KCs
    | KDf
    | KD
    | KDn
    | KDs
    | KEf
    | KE
    | KEn
    | KF
    | KFn
    | KFs
    | KGf
    | KG
    | KGn
    | KGs
    | KAf
    | KA
    | KAn
    | KAs
    | KBf
    | KB
    | KBn


type KeySignature
    = KS_N
    | KS_xF
    | KS_xFC
    | KS_xFCG
    | KS_xFCGD
    | KS_xFCGDA
    | KS_xFCGDAE
    | KS_xFCGDAEB
    | KS_bBEADGCF
    | KS_bBEADGC
    | KS_bBEADG
    | KS_bBEAD
    | KS_bBEA
    | KS_bBE
    | KS_bB


type KeyboardKeyPress
    = Sounding KeyNoteName Octave
    | Muted KeyNoteName Octave


type alias KeyboardModel msg =
    { query : KeyboardQuery
    , notation : Maybe String -- the rendered SVG
    , needsProbe : Bool
    , inputIsValid : Bool
    , paeInputSearchDebouncer : Debouncer msg
    , paeHelpExpanded : Bool
    , notesPlaying : List ( KeyNoteName, Octave )
    }


type alias KeyboardQuery =
    { clef : Clef
    , timeSignature : TimeSignature
    , keySignature : KeySignature
    , noteData : Maybe String
    , queryMode : QueryMode
    }


type alias Octave =
    Int


type alias Octaves =
    List ( Int, String )


type QueryMode
    = IntervalQueryMode
    | ExactPitchQueryMode


type TimeSignature
    = TNone
    | T4_4
    | T3_4
    | TC
    | TCutC
    | T6_8
    | TO
    | TODot



--type alias TimeSignature =
--    String
--type alias KeySignature =
--    String


setClef : Clef -> { a | clef : Clef } -> { a | clef : Clef }
setClef newClef oldModel =
    { oldModel | clef = newClef }


setKeySignature : KeySignature -> { a | keySignature : KeySignature } -> { a | keySignature : KeySignature }
setKeySignature newSig oldModel =
    { oldModel | keySignature = newSig }


setKeyboardQuery : KeyboardQuery -> { a | query : KeyboardQuery } -> { a | query : KeyboardQuery }
setKeyboardQuery newQuery oldModel =
    { oldModel | query = newQuery }


setNoteData : Maybe String -> { a | noteData : Maybe String } -> { a | noteData : Maybe String }
setNoteData newData oldModel =
    { oldModel | noteData = newData }


setQueryMode : QueryMode -> { a | queryMode : QueryMode } -> { a | queryMode : QueryMode }
setQueryMode newMode oldModel =
    { oldModel | queryMode = newMode }


setTimeSignature : TimeSignature -> { a | timeSignature : TimeSignature } -> { a | timeSignature : TimeSignature }
setTimeSignature newSig oldModel =
    { oldModel | timeSignature = newSig }


toKeyboardQuery : { a | query : KeyboardQuery } -> KeyboardQuery
toKeyboardQuery model =
    model.query
