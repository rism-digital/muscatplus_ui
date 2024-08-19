module Page.UI.Events exposing (onComplete, onEnter)

import Element
import Html.Events
import Json.Decode as Decode


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (Html.Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )
        )


onComplete : msg -> Element.Attribute msg
onComplete msg =
    Decode.succeed msg
        |> Html.Events.on "animationend"
        |> Element.htmlAttribute
