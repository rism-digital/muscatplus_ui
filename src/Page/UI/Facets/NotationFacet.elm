module Page.UI.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)

import Element exposing (Element, alignLeft, fill, row, width)
import Language exposing (Language, LanguageMap)
import Page.Keyboard as Keyboard
import Page.Keyboard.Model exposing (Keyboard(..))
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Search exposing (NotationFacet)


type alias NotationFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
    , keyboardModel : Keyboard.Model KeyboardMsg
    , notationFacet : NotationFacet
    , userInteractedWithKeyboardMsg : KeyboardMsg -> msg
    }


viewKeyboardControl : NotationFacetConfig msg -> Element msg
viewKeyboardControl { language, keyboardModel, notationFacet, userInteractedWithKeyboardMsg } =
    let
        keyboardConfig =
            { numOctaves = 3 }
    in
    row
        [ alignLeft
        , width fill
        ]
        [ Keyboard.view notationFacet language (Keyboard keyboardModel keyboardConfig)
            |> Element.map userInteractedWithKeyboardMsg
        ]
