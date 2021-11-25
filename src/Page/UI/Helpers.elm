module Page.UI.Helpers exposing (..)

import Element exposing (Attribute, Element, htmlAttribute, none)
import Html.Attributes as HTA


{-|

    A view helper that will either render the value of
    'body' with a given `viewFunc`, or return `Element.none`
    indicating nothing should be rendered.

    `viewFunc` can be partially applied with a `language` value
    allowing the body to be rendered in response to the user's
    selected language parameter.

-}
viewMaybe : (a -> Element msg) -> Maybe a -> Element msg
viewMaybe viewFunc body =
    Maybe.map viewFunc body
        |> Maybe.withDefault none
