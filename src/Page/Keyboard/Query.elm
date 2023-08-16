module Page.Keyboard.Query exposing
    ( buildNotationQueryParameters
    , notationParamParser
    , queryModeStrToQueryMode
    )

import Maybe.Extra as ME
import Page.Keyboard.Model
    exposing
        ( Clef(..)
        , KeySignature(..)
        , KeyboardQuery
        , QueryMode(..)
        , TimeSignature(..)
        )
import Page.Keyboard.PAE
    exposing
        ( clefQueryStringToClef
        , clefSymToClefQueryString
        , keySigStrToKeySignature
        , keySignatureSymToQueryStr
        , timeSigStrToTimeSignature
        , timeSignatureSymToQueryStr
        )
import Page.Keyboard.Utilities exposing (comparableToSymHelper, symToStringHelper)
import Request exposing (apply)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


queryModeMap : List ( String, QueryMode )
queryModeMap =
    [ ( "interval", IntervalQueryMode )
    , ( "exact-pitches", ExactPitchQueryMode )
    , ( "contour", ContourQueryMode )
    ]


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


buildNotationQueryParameters : KeyboardQuery -> List QueryParameter
buildNotationQueryParameters notationInput =
    let
        clefString =
            clefSymToClefQueryString notationInput.clef

        clef =
            if String.isEmpty clefString || (notationInput.clef == G2) then
                []

            else
                Url.Builder.string "ic" clefString
                    |> List.singleton

        ksigStr =
            keySignatureSymToQueryStr notationInput.keySignature

        keySignature =
            if String.isEmpty ksigStr || ksigStr == "n" then
                []

            else
                Url.Builder.string "ik" ksigStr
                    |> List.singleton

        notes =
            ME.unwrap []
                (\noteString ->
                    Url.Builder.string "n" noteString
                        |> List.singleton
                )
                notationInput.noteData

        queryMode =
            -- only add the 'im' parameter if we're looking for exact pitches
            -- since the interval mode is the default.
            if notationInput.queryMode == IntervalQueryMode then
                []

            else
                queryModeToQueryModeStr notationInput.queryMode
                    |> Url.Builder.string "im"
                    |> List.singleton

        tsigStr =
            timeSignatureSymToQueryStr notationInput.timeSignature

        timeSignature =
            if String.isEmpty tsigStr || tsigStr == "-" then
                []

            else
                Url.Builder.string "it" tsigStr
                    |> List.singleton
    in
    List.concat [ notes, clef, timeSignature, keySignature, queryMode ]



-- Keyboard Query Parameters


clefParamParser : Q.Parser Clef
clefParamParser =
    Q.custom "ic" (\a -> clefQueryStringToClef a)


keySigParamParser : Q.Parser KeySignature
keySigParamParser =
    Q.custom "ik" (\a -> keySigQueryStringToKeySignature a)


keySigQueryStringToKeySignature : List String -> KeySignature
keySigQueryStringToKeySignature ksiglist =
    List.head ksiglist
        |> Maybe.map (\a -> keySigStrToKeySignature a)
        |> Maybe.withDefault KS_N


notationParamParser : Q.Parser KeyboardQuery
notationParamParser =
    Q.map KeyboardQuery clefParamParser
        |> apply timeSigParamParser
        |> apply keySigParamParser
        |> apply noteDataParamParser
        |> apply queryModeParamParser


noteDataParamParser : Q.Parser (Maybe String)
noteDataParamParser =
    Q.custom "n"
        (\a ->
            if List.isEmpty a then
                Nothing

            else
                Just (noteDataQueryStringToList a)
        )


noteDataQueryStringToList : List String -> String
noteDataQueryStringToList ndata =
    List.head ndata
        |> Maybe.withDefault ""


queryModeParamParser : Q.Parser QueryMode
queryModeParamParser =
    Q.custom "im" (\a -> queryModeStringToQueryMode a)


queryModeStringToQueryMode : List String -> QueryMode
queryModeStringToQueryMode qmlist =
    List.head qmlist
        |> Maybe.map (\a -> queryModeStrToQueryMode a)
        |> Maybe.withDefault IntervalQueryMode


timeSigParamParser : Q.Parser TimeSignature
timeSigParamParser =
    Q.custom "it" (\a -> timeSigQueryStringToTimeSignature a)


timeSigQueryStringToTimeSignature : List String -> TimeSignature
timeSigQueryStringToTimeSignature tsiglist =
    List.head tsiglist
        |> Maybe.map (\a -> timeSigStrToTimeSignature a)
        |> Maybe.withDefault TNone
