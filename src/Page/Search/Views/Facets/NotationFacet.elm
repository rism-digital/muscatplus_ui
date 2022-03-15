module Page.Search.Views.Facets.NotationFacet exposing (..)

import Element exposing (Element, centerX, row)
import Language exposing (Language)
import Page.UI.Keyboard as Keyboard
import Page.UI.Keyboard.Model exposing (Keyboard(..))
import Page.UI.Keyboard.Msg exposing (KeyboardMsg)


type alias NotationFacetConfig msg =
    { language : Language
    , keyboardFacet : Keyboard.Model
    , userInteractedWithKeyboardMsg : KeyboardMsg -> msg
    }


viewKeyboardControl : NotationFacetConfig msg -> Element msg
viewKeyboardControl config =
    let
        keyboardConfig =
            { numOctaves = 3 }
    in
    row
        [ centerX ]
        [ Keyboard.view config.language (Keyboard config.keyboardFacet keyboardConfig)
            |> Element.map config.userInteractedWithKeyboardMsg
        ]
