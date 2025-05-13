module Mobile.Error.Views exposing (view)

import Element exposing (Element, fill, height, none, row, width)
import Response exposing (Response)
import Session exposing (Session)


view :
    Session
    -> { a | response : Response data }
    -> Element msg
view session model =
    row
        [ width fill
        , height fill
        ]
        []
