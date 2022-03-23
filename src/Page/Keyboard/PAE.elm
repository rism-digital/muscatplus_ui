module Page.Keyboard.PAE exposing (..)

import Dict
import Page.Keyboard.Model exposing (Clef(..), KeyNoteName(..), KeySignature(..), Octave, QueryMode(..), TimeSignature(..), clefStringMap, keySignatureMap, noteMap, queryModeMap, supportedOctaves, timeSignatureMap)


{-|

    Takes a list of (String, a) and returns the first string value for a given 'a', or a default value
    if that 'a' is not found in the list.

-}
symToStringHelper :
    { valueMap : List ( String, a )
    , defaultValue : String
    , target : a
    }
    -> String
symToStringHelper cfg =
    List.filter (\( _, cc ) -> cc == cfg.target) cfg.valueMap
        |> List.map (\( s, _ ) -> s)
        |> List.head
        |> Maybe.withDefault cfg.defaultValue


{-| Takes a list of (comparable, sym) and returns the sym for a given comparable, with a
default value specified if that comparable is not available in the list.
-}
comparableToSymHelper :
    { valueMap : List ( comparable, sym )
    , defaultValue : sym
    , target : comparable
    }
    -> sym
comparableToSymHelper cfg =
    Dict.fromList cfg.valueMap
        |> Dict.get cfg.target
        |> Maybe.withDefault cfg.defaultValue


{-|

    Gets the octave shift character for a given octave number.

    Assumes "'" (C4) by default.

-}
octaveShift : Int -> String
octaveShift octNum =
    comparableToSymHelper
        { valueMap = supportedOctaves
        , defaultValue = "'"
        , target = octNum
        }


clefQueryStringToClef : List String -> Clef
clefQueryStringToClef clefList =
    List.head clefList
        |> Maybe.withDefault ""
        |> clefStrToClef


clefStrToClef : String -> Clef
clefStrToClef clefStr =
    comparableToSymHelper
        { valueMap = clefStringMap
        , defaultValue = G2
        , target = clefStr
        }


clefSymToClefQueryString : Clef -> String
clefSymToClefQueryString clefSym =
    symToStringHelper
        { valueMap = clefStringMap
        , defaultValue = "G-2"
        , target = clefSym
        }


keyNoteNameToNoteString : KeyNoteName -> String
keyNoteNameToNoteString keyName =
    symToStringHelper
        { valueMap = noteMap
        , defaultValue = "C"
        , target = keyName
        }


createPAENote : KeyNoteName -> Octave -> String
createPAENote noteName octave =
    let
        octaveModifier =
            octaveShift octave

        noteString =
            keyNoteNameToNoteString noteName
    in
    String.concat [ octaveModifier, noteString ]


queryModeStrToQueryMode : String -> QueryMode
queryModeStrToQueryMode modeStr =
    comparableToSymHelper
        { valueMap = queryModeMap
        , defaultValue = IntervalQueryMode
        , target = modeStr
        }


queryModeToQueryModeStr : QueryMode -> String
queryModeToQueryModeStr mode =
    symToStringHelper
        { valueMap = queryModeMap
        , defaultValue = "interval"
        , target = mode
        }


timeSignatureSymToQueryStr : TimeSignature -> String
timeSignatureSymToQueryStr timeSignature =
    symToStringHelper
        { valueMap = timeSignatureMap
        , defaultValue = ""
        , target = timeSignature
        }


timeSigStrToTimeSignature : String -> TimeSignature
timeSigStrToTimeSignature tsigStr =
    comparableToSymHelper
        { valueMap = timeSignatureMap
        , defaultValue = TC
        , target = tsigStr
        }


keySignatureSymToQueryStr : KeySignature -> String
keySignatureSymToQueryStr timeSignature =
    symToStringHelper
        { valueMap = keySignatureMap
        , defaultValue = ""
        , target = timeSignature
        }


keySigStrToKeySignature : String -> KeySignature
keySigStrToKeySignature ksigStr =
    comparableToSymHelper
        { valueMap = keySignatureMap
        , defaultValue = KS_N
        , target = ksigStr
        }
