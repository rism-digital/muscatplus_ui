module Utilities exposing
    ( choose
    , convertNodeIdToPath
    , convertPathToNodeId
    , fromListDedupe
    , namedValue
    , toLinkedHtml
    , toggle
    )

import Dict exposing (Dict)
import Element exposing (Element)
import ElmEscapeHtml
import Html.Parser exposing (Node)
import Html.Parser.Util exposing (toVirtualDom)
import Maybe.Extra as ME
import Regex
import Set exposing (Set)


toggle : comparable -> Set comparable -> Set comparable
toggle needle haystack =
    if Set.member needle haystack then
        Set.remove needle haystack

    else
        Set.insert needle haystack


choose : Bool -> (() -> a) -> (() -> a) -> a
choose predicate isTrue isFalse =
    if predicate then
        isTrue ()

    else
        isFalse ()


convertNodeIdToPath : String -> String
convertNodeIdToPath nodeId =
    String.replace "-" "/" nodeId


convertPathToNodeId : String -> String
convertPathToNodeId recordPath =
    String.replace "/" "-" recordPath


{-|

    Creates a dictionary from a list, de-duplicating any keys

-}
fromListDedupe : (a -> a -> a) -> List ( comparable, a ) -> Dict comparable a
fromListDedupe combine xs =
    List.foldl
        (\( key, value ) acc -> insertDedupe combine key value acc)
        Dict.empty
        xs


insertDedupe : (v -> v -> v) -> comparable -> v -> Dict comparable v -> Dict comparable v
insertDedupe combine key value dict =
    let
        with mbValue =
            ME.unpack (\() -> Just value) (\oldValue -> Just (combine oldValue value)) mbValue
    in
    Dict.update key with dict


{-| Interpolate a named placeholder
"What happened to the {{ food }}? Maybe {{ person }} ate it?"
|> String.Format.namedValue "food" "cake"
|> String.Format.namedValue "person" "Joe"
-- "What happened to the cake? Maybe Joe ate it?"

Minimal code taken from

<https://github.com/jorgengranseth/elm-string-format/blob/1.0.1/src/String/Format.elm>

-}
namedValue : String -> String -> String -> String
namedValue name val =
    let
        placeholder =
            regex ("{{\\s*" ++ name ++ "\\s*}}")
    in
    Regex.replace placeholder (\_ -> val)


regex : String -> Regex.Regex
regex =
    Regex.fromString
        >> Maybe.withDefault Regex.never


{-| Utility functions to work with html.

@docs mapHrefRecursive
@docs postBodyToVirtualDom

From <https://gist.github.com/panthershark/d6e4fee5b5d07ee500683cd989ae69a8>
Uses hecrj/html-parser
parsed an html string, transforms hrefs in links, and converts to vdom which can be used in views.

-}
toLinkedHtml : String -> List (Element msg)
toLinkedHtml htmlString =
    let
        wrappedUrlString =
            Regex.replace
                (regex "(?<!href=\")(https?:\\/\\/\\S+)")
                (\match -> "<a href=\"" ++ match.match ++ "\">" ++ match.match ++ "</a>")
                htmlString
    in
    case Html.Parser.run wrappedUrlString of
        Ok nodes ->
            toElementList nodes

        Err _ ->
            let
                -- try again but first aggressively escape any characters that may be
                -- masquerading as HTML, such as "<" or ">". This may make really bad
                -- HTML show up in the notes, but it's better than showing nothing.
                escapedHtml =
                    ElmEscapeHtml.escape wrappedUrlString
            in
            case Html.Parser.run escapedHtml of
                Ok nodes ->
                    toElementList nodes

                Err _ ->
                    -- return the original string
                    [ Element.paragraph
                        []
                        [ Element.text htmlString ]
                    ]


toElementList : List Node -> List (Element msg)
toElementList htmlNodes =
    toVirtualDom htmlNodes
        |> List.map Element.html
        |> Element.paragraph []
        |> List.singleton
