module Viewport exposing (..)

import Browser.Dom as Dom
import Msg exposing (Msg(..))
import Task


{-|

    Scrolls the Browser viewport so that the ID is visible.

-}
jumpToId : String -> Cmd Msg
jumpToId id =
    Dom.getElement id
        |> Task.andThen
            (\info ->
                -- set a small 10 pixel offset so that the element is slightly
                -- below the viewport edge. This makes the heading easier to spot.
                Dom.setViewport 0 (info.element.y - 10)
            )
        |> Task.attempt
            (\_ ->
                NoOp
            )


resetViewport : Cmd Msg
resetViewport =
    Dom.setViewport 0 0
        |> Task.attempt (\_ -> NoOp)
