module Page.UI.Keyboard.Query exposing (..)

import Page.UI.Keyboard.Model exposing (Clef(..), KeySignature, KeyboardQuery, TimeSignature)
import Page.UI.Keyboard.PAE exposing (clefQueryStringToClef, clefSymToClefQueryString)
import Request exposing (apply)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


buildNotationQueryParameters : KeyboardQuery -> List QueryParameter
buildNotationQueryParameters notationInput =
    let
        notes =
            case notationInput.noteData of
                Just noteString ->
                    List.singleton (Url.Builder.string "n" noteString)

                Nothing ->
                    []

        clefString =
            clefSymToClefQueryString notationInput.clef

        clef =
            if String.isEmpty clefString || (notationInput.clef == G2) then
                []

            else
                List.singleton (Url.Builder.string "ic" clefString)

        timeSignature =
            if String.isEmpty notationInput.timeSignature then
                []

            else
                List.singleton (Url.Builder.string "it" notationInput.timeSignature)

        keySignature =
            if String.isEmpty notationInput.keySignature then
                []

            else
                List.singleton (Url.Builder.string "ik" notationInput.keySignature)
    in
    List.concat [ notes, clef, timeSignature, keySignature ]



-- Keyboard Query Parameters


clefParamParser : Q.Parser Clef
clefParamParser =
    Q.custom "ic" (\a -> clefQueryStringToClef a)


timeSigParamParser : Q.Parser TimeSignature
timeSigParamParser =
    Q.custom "it" (\a -> timeSigQueryStringToTimeSignature a)


keySigParamParser : Q.Parser KeySignature
keySigParamParser =
    Q.custom "ik" (\a -> keySigQueryStringToKeySignature a)


timeSigQueryStringToTimeSignature : List String -> TimeSignature
timeSigQueryStringToTimeSignature tsiglist =
    List.head tsiglist
        |> Maybe.withDefault ""


keySigQueryStringToKeySignature : List String -> KeySignature
keySigQueryStringToKeySignature ksiglist =
    List.head ksiglist
        |> Maybe.withDefault ""


notationParamParser : Q.Parser KeyboardQuery
notationParamParser =
    Q.map KeyboardQuery clefParamParser
        |> apply timeSigParamParser
        |> apply keySigParamParser
        |> apply (Q.string "n")
