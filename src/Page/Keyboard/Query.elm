module Page.Keyboard.Query exposing (..)

import Page.Keyboard.Model exposing (Clef(..), KeySignature(..), KeyboardQuery, QueryMode(..), TimeSignature(..))
import Page.Keyboard.PAE exposing (clefQueryStringToClef, clefSymToClefQueryString, keySigStrToKeySignature, keySignatureSymToQueryStr, queryModeStrToQueryMode, queryModeToQueryModeStr, timeSigStrToTimeSignature, timeSignatureSymToQueryStr)
import Request exposing (apply)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


buildNotationQueryParameters : KeyboardQuery -> List QueryParameter
buildNotationQueryParameters notationInput =
    let
        notes =
            case notationInput.noteData of
                Just noteString ->
                    Url.Builder.string "n" noteString
                        |> List.singleton

                Nothing ->
                    []

        clefString =
            clefSymToClefQueryString notationInput.clef

        clef =
            if String.isEmpty clefString || (notationInput.clef == G2) then
                []

            else
                Url.Builder.string "ic" clefString
                    |> List.singleton

        tsigStr =
            timeSignatureSymToQueryStr notationInput.timeSignature

        timeSignature =
            if String.isEmpty tsigStr || tsigStr == "-" then
                []

            else
                Url.Builder.string "it" tsigStr
                    |> List.singleton

        ksigStr =
            keySignatureSymToQueryStr notationInput.keySignature

        keySignature =
            if String.isEmpty ksigStr || ksigStr == "n" then
                []

            else
                Url.Builder.string "ik" ksigStr
                    |> List.singleton

        queryMode =
            if notationInput.queryMode == IntervalQueryMode then
                []

            else
                queryModeToQueryModeStr notationInput.queryMode
                    |> Url.Builder.string "im"
                    |> List.singleton
    in
    List.concat [ notes, clef, timeSignature, keySignature, queryMode ]



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


noteDataParamParser : Q.Parser (Maybe String)
noteDataParamParser =
    Q.custom "n"
        (\a ->
            if List.isEmpty a then
                Nothing

            else
                Just <| noteDataQueryStringToList a
        )


queryModeParamParser : Q.Parser QueryMode
queryModeParamParser =
    Q.custom "im" (\a -> queryModeStringToQueryMode a)


noteDataQueryStringToList : List String -> String
noteDataQueryStringToList ndata =
    List.head ndata
        |> Maybe.withDefault ""


timeSigQueryStringToTimeSignature : List String -> TimeSignature
timeSigQueryStringToTimeSignature tsiglist =
    List.head tsiglist
        |> Maybe.map (\a -> timeSigStrToTimeSignature a)
        |> Maybe.withDefault TC


keySigQueryStringToKeySignature : List String -> KeySignature
keySigQueryStringToKeySignature ksiglist =
    List.head ksiglist
        |> Maybe.map (\a -> keySigStrToKeySignature a)
        |> Maybe.withDefault KS_N


queryModeStringToQueryMode : List String -> QueryMode
queryModeStringToQueryMode qmlist =
    List.head qmlist
        |> Maybe.map (\a -> queryModeStrToQueryMode a)
        |> Maybe.withDefault IntervalQueryMode


notationParamParser : Q.Parser KeyboardQuery
notationParamParser =
    Q.map KeyboardQuery clefParamParser
        |> apply timeSigParamParser
        |> apply keySigParamParser
        |> apply noteDataParamParser
        |> apply queryModeParamParser
