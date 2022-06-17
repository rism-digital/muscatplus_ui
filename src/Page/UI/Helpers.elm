module Page.UI.Helpers exposing (viewIf, viewMaybe)

import Element exposing (Element, none)


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
