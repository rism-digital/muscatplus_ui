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
    = G2
    | C1
    | C2
    | F4
    | C3
    | C1M
    | C2M
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
    [ ( "G-2", G2 )
    , ( "C-1", C1 )
    , ( "C-2", C2 )
    , ( "F-4", F4 )
    , ( "C-3", C3 )
    , ( "G+2", G2M )
    , ( "C+1", C1M )
    , ( "C+2", C2M )
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


queryModeMap : List ( String, QueryMode )
queryModeMap =
    [ ( "interval", IntervalQueryMode )
    , ( "exact-pitches", ExactPitchQueryMode )
    ]
