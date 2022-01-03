module Subscriptions exposing (subscriptions)

import Browser.Events exposing (onResize)
import Device exposing (detectDevice)
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.Search.Msg as SearchMsg
import Ports.Incoming exposing (incomingSearchActionTriggered)


{-|

    When a user sets their national collection, it makes sense to refresh
    their search results, if they are on the search page. This helper listens
    for an incoming message from the JS Port, and then if the current page
    is the search page, will trigger a 'search submit'. This will then apply
    the `nc` filter to the search results, and limit it to only results from
    that national collection.

-}
handleIncomingSearchTrigger : Model -> Msg
handleIncomingSearchTrigger model =
    case model of
        SearchPage _ _ ->
            Msg.UserInteractedWithSearchPage SearchMsg.UserTriggeredSearchSubmit

        _ ->
            Msg.NothingHappened


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize <|
            \width height -> Msg.UserResizedWindow (detectDevice width height)
        , incomingSearchActionTriggered <|
            \_ -> handleIncomingSearchTrigger model
        ]
