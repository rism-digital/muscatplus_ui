module Page.UI.Keyboard.Model exposing (..)


type Keyboard
    = Keyboard KeyboardModel KeyboardConfig


type alias KeyboardModel =
    { query : KeyboardQuery
    , notation : Maybe String
    }


type alias KeyboardQuery =
    { clef : Clef
    , timeSignature : TimeSignature
    , keySignature : KeySignature
    , noteData : Maybe (List String)
    }


type Key
    = WhiteKey KeyNoteName
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
    | KCs
    | KDf
    | KD
    | KDs
    | KEf
    | KE
    | KF
    | KFs
    | KGf
    | KG
    | KGs
    | KAf
    | KA
    | KAs
    | KBf
    | KB


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
    , ( "xC", KCs )
    , ( "bD", KDf )
    , ( "D", KD )
    , ( "xD", KDs )
    , ( "bE", KEf )
    , ( "E", KE )
    , ( "F", KF )
    , ( "xF", KFs )
    , ( "bG", KGf )
    , ( "G", KG )
    , ( "xG", KGs )
    , ( "bA", KAf )
    , ( "A", KA )
    , ( "xA", KAs )
    , ( "bB", KBf )
    , ( "B", KB )
    ]
