module UI.Icons exposing (..)

import Element exposing (Element, html)
import Heroicons.Outline as Icon
import Html.Attributes exposing (style)


modeIcons :
    { sources : Element msg
    , people : Element msg
    , institutions : Element msg
    , incipits : Element msg
    , unknown : Element msg
    }
modeIcons =
    let
        iconWidth =
            style "width" "1rem"
    in
    { sources = html (Icon.bookOpen [ iconWidth ])
    , people = html (Icon.userGroup [ iconWidth ])
    , institutions = html (Icon.library [ iconWidth ])
    , incipits = html (Icon.musicNote [ iconWidth ])
    , unknown = html (Icon.x [ iconWidth ])
    }
