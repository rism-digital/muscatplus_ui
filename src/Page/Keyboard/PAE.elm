module Page.Keyboard.PAE exposing
    ( clefQueryStringToClef
    , clefStrToClef
    , clefSymToClefQueryString
    , createPAENote
    , keyNoteNameToNoteString
    , keySigStrToKeySignature
    , keySignatureSymToQueryStr
    , queryModeStrToQueryMode
    , queryModeToQueryModeStr
    , timeSigStrToTimeSignature
    , timeSignatureSymToQueryStr
    )

import Dict
import Page.Keyboard.Model
    exposing
        ( Clef(..)
        , KeyNoteName
        , KeySignature(..)
        , Octave
        , QueryMode(..)
        , TimeSignature(..)
        , clefStringMap
        , keySignatureMap
        , noteMap
        , queryModeMap
        , supportedOctaves
        , timeSignatureMap
        )


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


{-| Takes a list of (comparable, sym) and returns the sym for a given comparable, with a
default value specified if that comparable is not available in the list.
-}
comparableToSymHelper :
    { defaultValue : sym
    , target : comparable
    , valueMap : List ( comparable, sym )
    }
    -> sym
comparableToSymHelper cfg =
    Dict.fromList cfg.valueMap
        |> Dict.get cfg.target
        |> Maybe.withDefault cfg.defaultValue


createPAENote : KeyNoteName -> Octave -> String
createPAENote noteName octave =
    let
        noteString =
            keyNoteNameToNoteString noteName

        octaveModifier =
            octaveShift octave
    in
    String.concat [ octaveModifier, noteString ]


keyNoteNameToNoteString : KeyNoteName -> String
keyNoteNameToNoteString keyName =
    symToStringHelper
        { defaultValue = "C"
        , target = keyName
        , valueMap = noteMap
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


queryModeStrToQueryMode : String -> QueryMode
queryModeStrToQueryMode modeStr =
    comparableToSymHelper
        { defaultValue = IntervalQueryMode
        , target = modeStr
        , valueMap = queryModeMap
        }


queryModeToQueryModeStr : QueryMode -> String
queryModeToQueryModeStr mode =
    symToStringHelper
        { defaultValue = "interval"
        , target = mode
        , valueMap = queryModeMap
        }


{-|

    Takes a list of (String, a) and returns the first string value for a given 'a', or a default value
    if that 'a' is not found in the list.

-}
symToStringHelper :
    { defaultValue : String
    , target : a
    , valueMap : List ( String, a )
    }
    -> String
symToStringHelper cfg =
    List.filter (\( _, cc ) -> cc == cfg.target) cfg.valueMap
        |> List.map (\( s, _ ) -> s)
        |> List.head
        |> Maybe.withDefault cfg.defaultValue


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
