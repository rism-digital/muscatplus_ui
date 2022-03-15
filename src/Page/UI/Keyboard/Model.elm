module Page.UI.Keyboard.Model exposing (..)


type Keyboard
    = Keyboard KeyboardModel KeyboardConfig


type KeyboardInputMode
    = PianoInput
    | FormInput


type alias KeyboardModel =
    { query : KeyboardQuery
    , notation : Maybe String -- the rendered SVG
    , needsProbe : Bool
    , inputMode : KeyboardInputMode
    }


toKeyboardQuery : { a | query : KeyboardQuery } -> KeyboardQuery
toKeyboardQuery model =
    model.query


type alias KeyboardQuery =
    { clef : Clef
    , timeSignature : TimeSignature
    , keySignature : KeySignature
    , noteData : Maybe (List String)
    }


setNoteData : Maybe (List String) -> { a | noteData : Maybe (List String) } -> { a | noteData : Maybe (List String) }
setNoteData newData oldModel =
    { oldModel | noteData = newData }


type Key
    = WhiteKey KeyNoteName KeyNoteName
    | BlackKey KeyNoteName KeyNoteName


type alias KeyboardConfig =
    { numOctaves : Int
    }


type alias Octave =
    Int


type alias Octaves =
    List ( Int, String )


{-|

    "M" indicates a mensural clef

-}
type Clef
    = G2
    | C1
    | F4
    | C3
    | C1M
    | G2M
    | C3M


type alias TimeSignature =
    String


type alias KeySignature =
    String


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


supportedOctaves : Octaves
supportedOctaves =
    [ ( 1, ",,," )
    , ( 2, ",," )
    , ( 3, "," )
    , ( 4, "'" )
    , ( 5, "''" )
    , ( 6, "'''" )
    , ( 7, "''''" )
    ]


clefStringMap : List ( String, Clef )
clefStringMap =
    [ ( "G-2", G2 )
    , ( "C-1", C1 )
    , ( "F-4", F4 )
    , ( "C-3", C3 )
    , ( "C+1", C1M )
    , ( "G+2", G2M )
    , ( "C+3", C3M )
    ]


noteMap : List ( String, KeyNoteName )
noteMap =
    [ ( "C", KC )
    , ( "nC", KCn )
    , ( "xC", KCs )
    , ( "bD", KDf )
    , ( "D", KD )
    , ( "nD", KDn )
    , ( "xD", KDs )
    , ( "bE", KEf )
    , ( "E", KE )
    , ( "nE", KEn )
    , ( "F", KF )
    , ( "nF", KFn )
    , ( "xF", KFs )
    , ( "bG", KGf )
    , ( "G", KG )
    , ( "nG", KGn )
    , ( "xG", KGs )
    , ( "bA", KAf )
    , ( "A", KA )
    , ( "nA", KAn )
    , ( "xA", KAs )
    , ( "bB", KBf )
    , ( "B", KB )
    , ( "nB", KBn )
    ]
