module Page.Search.Views.Facets.NotationFacet exposing (..)

import Element exposing (Element, alignLeft, fill, row, width)
import Language exposing (Language)
import Page.Keyboard as Keyboard
import Page.Keyboard.Model exposing (Keyboard(..))
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Search exposing (NotationFacet)


type alias NotationFacetConfig msg =
    { language : Language
    , keyboardModel : Keyboard.Model
    , notationFacet : NotationFacet
    , userInteractedWithKeyboardMsg : KeyboardMsg -> msg
    }


viewKeyboardControl : NotationFacetConfig msg -> Element msg
viewKeyboardControl config =
    let
        keyboardConfig =
            { numOctaves = 3 }
    in
    row
        [ alignLeft
        , width fill
        ]
        [ Keyboard.view config.notationFacet config.language (Keyboard config.keyboardModel keyboardConfig)
            |> Element.map config.userInteractedWithKeyboardMsg
        ]
