module Mobile.Error.Views exposing (view)

import Element exposing (Element, none)
import Response exposing (Response)
import Session exposing (Session)


view :
    Session
    -> { a | response : Response data }
    -> Element msg
view session model =
    none
