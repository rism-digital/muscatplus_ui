module Page.Keyboard.PAE exposing
    ( clefQueryStringToClef
    , clefStrToClef
    , clefSymToClefQueryString
    , createPAENote
    , keyNoteNameToHumanNoteString
    , keySigStrToKeySignature
    , keySignatureSymToQueryStr
    , timeSigStrToTimeSignature
    , timeSignatureSymToQueryStr
    )

import Page.Keyboard.Model exposing (Clef(..), KeyNoteName(..), KeySignature(..), Octave, Octaves, TimeSignature(..))
import Page.Keyboard.Utilities exposing (comparableToSymHelper, symToStringHelper)


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


humanNoteMap : List ( String, KeyNoteName )
humanNoteMap =
    [ ( "C", KC )
    , ( "C♮", KCn )
    , ( "C♯", KCs )
    , ( "D♭", KDf )
    , ( "D", KD )
    , ( "D♮", KDn )
    , ( "D♯", KDs )
    , ( "E♭", KEf )
    , ( "E", KE )
    , ( "E♮", KEn )
    , ( "F", KF )
    , ( "F♮", KFn )
    , ( "F♯", KFs )
    , ( "G♭", KGf )
    , ( "G", KG )
    , ( "G♮", KGn )
    , ( "G♯", KGs )
    , ( "A♭", KAf )
    , ( "A", KA )
    , ( "A♮", KAn )
    , ( "A♯", KAs )
    , ( "B♭", KBf )
    , ( "B", KB )
    , ( "B♮", KBn )
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


clefQueryStringToClef : List String -> Clef
clefQueryStringToClef clefList =
    List.head clefList
        |> Maybe.withDefault ""
        |> clefStrToClef


clefStrToClef : String -> Clef
clefStrToClef clefStr =
    comparableToSymHelper
        { defaultValue = G2
        , target = clefStr
        , valueMap = clefStringMap
        }


clefSymToClefQueryString : Clef -> String
clefSymToClefQueryString clefSym =
    symToStringHelper
        { defaultValue = "G-2"
        , target = clefSym
        , valueMap = clefStringMap
        }


createPAENote : KeyNoteName -> Octave -> String
createPAENote noteName octave =
    String.concat
        [ octaveShift octave
        , keyNoteNameToNoteString noteName
        ]


keyNoteNameToNoteString : KeyNoteName -> String
keyNoteNameToNoteString keyName =
    symToStringHelper
        { defaultValue = "C"
        , target = keyName
        , valueMap = noteMap
        }


keyNoteNameToHumanNoteString : KeyNoteName -> String
keyNoteNameToHumanNoteString keyName =
    symToStringHelper
        { defaultValue = "C"
        , target = keyName
        , valueMap = humanNoteMap
        }


keySigStrToKeySignature : String -> KeySignature
keySigStrToKeySignature ksigStr =
    comparableToSymHelper
        { defaultValue = KS_N
        , target = ksigStr
        , valueMap = keySignatureMap
        }


keySignatureSymToQueryStr : KeySignature -> String
keySignatureSymToQueryStr timeSignature =
    symToStringHelper
        { defaultValue = ""
        , target = timeSignature
        , valueMap = keySignatureMap
        }


{-|

    Gets the octave shift character for a given octave number.

    Assumes "'" (C4) by default.

-}
octaveShift : Int -> String
octaveShift octNum =
    comparableToSymHelper
        { defaultValue = "'"
        , target = octNum
        , valueMap = supportedOctaves
        }


timeSigStrToTimeSignature : String -> TimeSignature
timeSigStrToTimeSignature tsigStr =
    comparableToSymHelper
        { defaultValue = TC
        , target = tsigStr
        , valueMap = timeSignatureMap
        }


timeSignatureSymToQueryStr : TimeSignature -> String
timeSignatureSymToQueryStr timeSignature =
    symToStringHelper
        { defaultValue = ""
        , target = timeSignature
        , valueMap = timeSignatureMap
        }
