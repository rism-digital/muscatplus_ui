module Records.Views.Place exposing (..)

import Element exposing (Element, none)
import Records.DataTypes exposing (Msg, PlaceBody)
import Shared.Language exposing (Language)


viewPlaceRecord : PlaceBody -> Language -> Element Msg
viewPlaceRecord body language =
    none
