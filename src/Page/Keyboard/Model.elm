module Page.Keyboard.Model exposing (..)


type Keyboard
    = Keyboard KeyboardModel KeyboardConfig


type alias KeyboardModel =
    { query : KeyboardQuery
    , notation : Maybe String -- the rendered SVG
    , needsProbe : Bool
    , inputIsValid : Bool
    }


type alias KeyNoteConfig =
    { keyType : Key
    }


octaveConfig : List KeyNoteConfig
octaveConfig =
    [ { keyType = WhiteKey KC KCn
      }
    , { keyType = BlackKey KCs KDf
      }
    , { keyType = WhiteKey KD KDn
      }
    , { keyType = BlackKey KDs KEf
      }
    , { keyType = WhiteKey KE KEn
      }
    , { keyType = WhiteKey KF KFn
      }
    , { keyType = BlackKey KFs KGf
      }
    , { keyType = WhiteKey KG KGn
      }
    , { keyType = BlackKey KGs KAf
      }
    , { keyType = WhiteKey KA KAn
      }
    , { keyType = BlackKey KAs KBf
      }
    , { keyType = WhiteKey KB KBn
      }
    ]


toKeyboardQuery : { a | query : KeyboardQuery } -> KeyboardQuery
toKeyboardQuery model =
    model.query


setKeyboardQuery : KeyboardQuery -> { a | query : KeyboardQuery } -> { a | query : KeyboardQuery }
setKeyboardQuery newQuery oldModel =
    { oldModel | query = newQuery }


type alias KeyboardQuery =
    { clef : Clef
    , timeSignature : TimeSignature
    , keySignature : KeySignature
    , noteData : Maybe String
    , queryMode : QueryMode
    }


setNoteData : Maybe String -> { a | noteData : Maybe String } -> { a | noteData : Maybe String }
setNoteData newData oldModel =
    { oldModel | noteData = newData }


setClef : Clef -> { a | clef : Clef } -> { a | clef : Clef }
setClef newClef oldModel =
    { oldModel | clef = newClef }


setTimeSignature : TimeSignature -> { a | timeSignature : TimeSignature } -> { a | timeSignature : TimeSignature }
setTimeSignature newSig oldModel =
    { oldModel | timeSignature = newSig }


setKeySignature : KeySignature -> { a | keySignature : KeySignature } -> { a | keySignature : KeySignature }
setKeySignature newSig oldModel =
    { oldModel | keySignature = newSig }


setQueryMode : QueryMode -> { a | queryMode : QueryMode } -> { a | queryMode : QueryMode }
setQueryMode newMode oldModel =
    { oldModel | queryMode = newMode }


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



--type alias TimeSignature =
--    String


type TimeSignature
    = TNone
    | T4_4
    | T3_4
    | TC
    | TCutC
    | T6_8
    | TO
    | TODot



--type alias KeySignature =
--    String


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


type QueryMode
    = IntervalQueryMode
    | ExactPitchQueryMode


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
    [ ( "C-1", C1 )
    , ( "C-2", C2 )
    , ( "C-3", C3 )
    , ( "C-4", C4 )
    , ( "F-3", F3 )
    , ( "F-4", F4 )
    , ( "G-1", G1 )
    , ( "G-2", G2 )
    , ( "G-3", G3 )
    , ( "g-2", G2Oct )
    , ( "C+1", C1M )
    , ( "C+2", C2M )
    , ( "C+3", C3M )
    , ( "F+3", F3M )
    , ( "F+4", F4M )
    , ( "G+2", G2M )
    , ( "G+3", G3M )
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


queryModeMap : List ( String, QueryMode )
queryModeMap =
    [ ( "interval", IntervalQueryMode )
    , ( "exact-pitches", ExactPitchQueryMode )
    ]


keySignatureMap : List ( String, KeySignature )
keySignatureMap =
    [ ( "n", KS_N )
    , ( "xF", KS_xF )
    , ( "xFC", KS_xFC )
    , ( "xFCG", KS_xFCG )
    , ( "xFCGD", KS_xFCGD )
    , ( "xFCGDA", KS_xFCGDA )
    , ( "xFCGDAE", KS_xFCGDAE )
    , ( "xFCGDAEB", KS_xFCGDAEB )
    , ( "bBEADGCF", KS_bBEADGCF )
    , ( "bBEADGC", KS_bBEADGC )
    , ( "bBEADG", KS_bBEADG )
    , ( "bBEAD", KS_bBEAD )
    , ( "bBEA", KS_bBEA )
    , ( "bBE", KS_bBE )
    , ( "bB", KS_bB )
    ]


timeSignatureMap : List ( String, TimeSignature )
timeSignatureMap =
    [ ( "-", TNone )
    , ( "4/4", T4_4 )
    , ( "3/4", T3_4 )
    , ( "6/8", T6_8 )
    , ( "c", TC )
    , ( "c/", TCutC )
    , ( "o", TO )
    , ( "o.", TODot )
    ]
