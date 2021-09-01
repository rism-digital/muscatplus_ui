module Page.UI.Keyboard.PAE exposing (..)

import Dict
import Page.UI.Keyboard.Model exposing (Clef(..), KeyNoteName(..), Octave, clefStringMap, noteMap, supportedOctaves)


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
    let
        clefStr =
            List.head clefList
                |> Maybe.withDefault ""

        clefSym =
            List.filter (\( cs, _ ) -> cs == clefStr) clefStringMap
                |> Dict.fromList
                |> Dict.get clefStr
                |> Maybe.withDefault G2
    in
    clefSym


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
