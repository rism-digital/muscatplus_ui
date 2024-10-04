module Viewport exposing (jumpToIdIfNotVisible, resetViewportOf)

import Browser.Dom as Dom
import Task


jumpToIdIfNotVisible : msg -> String -> String -> Cmd msg
jumpToIdIfNotVisible sendMsg parentId id =
    Dom.getElement id
        |> Task.andThen
            (\info ->
                let
                    -- only consider the element to be in the viewport if the whole
                    -- element is visible
                    viewportBottom =
                        info.viewport.y + info.viewport.height

                    yPos =
                        info.element.y + info.element.height
                in
                if yPos > viewportBottom then
                    Dom.setViewportOf parentId 0 (info.element.y - info.element.height)

                else
                    Dom.setViewportOf "" 0 0
            )
        |> Task.attempt (\_ -> sendMsg)


resetViewportOf : msg -> String -> Cmd msg
resetViewportOf sendMsg id =
    Dom.setViewportOf id 0 0
        |> Task.attempt
            (\_ -> sendMsg)
