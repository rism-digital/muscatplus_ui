module Utlities exposing (..)

import Dict exposing (Dict)
import Element exposing (Element)
import Html.Parser exposing (Node(..))
import Html.Parser.Util exposing (toVirtualDom)
import Regex


flip : (a -> b -> c) -> b -> a -> c
flip function argB argA =
    function argA argB


insertDedupe : (v -> v -> v) -> comparable -> v -> Dict comparable v -> Dict comparable v
insertDedupe combine key value dict =
    let
        with mbValue =
            case mbValue of
                Just oldValue ->
                    Just <| combine oldValue value

                Nothing ->
                    Just value
    in
    Dict.update key with dict


fromListDedupe : (a -> a -> a) -> List ( comparable, a ) -> Dict comparable a
fromListDedupe combine xs =
    List.foldl
        (\( key, value ) acc -> insertDedupe combine key value acc)
        Dict.empty
        xs


{-|

    A generic filterMap function that operates on Dictionaries.

-}
filterMap : (comparable -> a -> Maybe b) -> Dict comparable a -> Dict comparable b
filterMap f dict =
    Dict.foldl
        (\k v acc ->
            case f k v of
                Just newVal ->
                    Dict.insert k newVal acc

                Nothing ->
                    acc
        )
        Dict.empty
        dict


{-| Utility functions to work with html.

@docs mapHrefRecursive
@docs postBodyToVirtualDom

From <https://gist.github.com/panthershark/d6e4fee5b5d07ee500683cd989ae69a8>
Uses hecrj/html-parser
parsed an html string, transforms hrefs in links, and converts to vdom which can be used in views.

-}
toLinkedHtml : String -> Result String (List (Element msg))
toLinkedHtml htmlString =
    case Html.Parser.run htmlString of
        Ok nodes ->
            let
                elementList =
                    toVirtualDom nodes
                        |> List.map Element.html
            in
            Ok elementList

        Err _ ->
            Err "Invalid Html"


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
            regex <| "{{\\s*" ++ name ++ "\\s*}}"
    in
    Regex.replace placeholder (\_ -> val)


regex : String -> Regex.Regex
regex =
    Regex.fromString
        >> Maybe.withDefault Regex.never
