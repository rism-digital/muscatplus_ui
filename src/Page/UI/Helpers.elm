module Page.UI.Helpers exposing (viewIf, viewMaybe, viewSVGRenderedIncipit)

import Element exposing (Element, none, text)
import SvgParser


viewIf : Element msg -> Bool -> Element msg
viewIf viewFunc condition =
    if condition then
        viewFunc

    else
        none


{-|

    A view helper that will either render the value of
    'body' with a given `viewFunc`, or return `Element.none`
    indicating nothing should be rendered.

    `viewFunc` can be partially applied with a `language` value
    allowing the body to be rendered in response to the user's
    selected language parameter.

-}
viewMaybe : (a -> Element msg) -> Maybe a -> Element msg
viewMaybe viewFunc maybeBody =
    Maybe.map viewFunc maybeBody
        |> Maybe.withDefault none


{-|

    Parses an Elm SVG tree (returns SVG data in Html) from the JSON incipit data.
    Converts it to an elm-ui structure to match the other view functions

-}
viewSVGRenderedIncipit : String -> Element msg
viewSVGRenderedIncipit incipitData =
    case SvgParser.parse incipitData of
        Ok svgData ->
            Element.html svgData

        Err _ ->
            text "Could not parse SVG"
