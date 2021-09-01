module Page.UI.Keyboard.Query exposing (..)

import Page.Query exposing (apply)
import Page.UI.Keyboard.Model exposing (Clef, KeySignature, KeyboardQuery, TimeSignature)
import Page.UI.Keyboard.PAE exposing (clefQueryStringToClef, clefSymToClefQueryString)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


buildNotationQueryParameters : KeyboardQuery -> List QueryParameter
buildNotationQueryParameters notationInput =
    let
        notes =
            Maybe.withDefault "" notationInput.noteData
                |> Url.Builder.string "n"
                |> List.singleton

        clef =
            List.singleton (Url.Builder.string "ic" (clefSymToClefQueryString notationInput.clef))

        timeSignature =
            List.singleton (Url.Builder.string "it" notationInput.timeSignature)

        keySignature =
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
        |> Maybe.withDefault "4/4"


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
