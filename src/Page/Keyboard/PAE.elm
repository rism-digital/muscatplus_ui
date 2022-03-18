module Page.Keyboard.PAE exposing (..)

import Dict
import Page.Keyboard.Model exposing (Clef(..), KeyNoteName(..), Octave, QueryMode(..), clefStringMap, noteMap, queryModeMap, supportedOctaves)


{-|

    Gets the octave shift character for a given octave number.

    Assumes "'" (C4) by default.

-}
octaveShift : Int -> String
octaveShift octNum =
    Dict.fromList supportedOctaves
        |> Dict.get octNum
        |> Maybe.withDefault "'"


clefQueryStringToClef : List String -> Clef
clefQueryStringToClef clefList =
    List.head clefList
        |> Maybe.withDefault ""
        |> clefStrToClef


clefStrToClef : String -> Clef
clefStrToClef clefStr =
    Dict.fromList clefStringMap
        |> Dict.get clefStr
        |> Maybe.withDefault G2


clefSymToClefQueryString : Clef -> String
clefSymToClefQueryString clefSym =
    List.filter (\( _, cc ) -> cc == clefSym) clefStringMap
        |> List.map (\( s, _ ) -> s)
        |> List.head
        |> Maybe.withDefault "G-2"


keyNoteNameToNoteString : KeyNoteName -> String
keyNoteNameToNoteString keyName =
    List.filter (\( ks, kk ) -> kk == keyName) noteMap
        |> List.head
        |> Maybe.withDefault ( "C", KC )
        |> Tuple.first


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
    Dict.fromList queryModeMap
        |> Dict.get modeStr
        |> Maybe.withDefault IntervalQueryMode


queryModeToQueryModeStr : QueryMode -> String
queryModeToQueryModeStr mode =
    List.filter (\( qs, qq ) -> qq == mode) queryModeMap
        |> List.head
        |> Maybe.withDefault ( "interval", IntervalQueryMode )
        |> Tuple.first
