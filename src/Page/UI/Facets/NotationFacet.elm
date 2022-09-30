module Page.UI.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)

import Element exposing (Element, alignLeft, fill, row, width)
import Language exposing (Language, LanguageMap)
import Page.Keyboard as Keyboard
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Search exposing (NotationFacet)
import SearchPreferences exposing (SearchPreferences)


type alias NotationFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
    , keyboardModel : Keyboard.Model KeyboardMsg
    , notationFacet : NotationFacet
    , userInteractedWithKeyboardMsg : KeyboardMsg -> msg
    , searchPreferences : Maybe SearchPreferences
    }


viewKeyboardControl : NotationFacetConfig msg -> Element msg
viewKeyboardControl { language, keyboardModel, notationFacet, userInteractedWithKeyboardMsg, searchPreferences } =
    row
        [ alignLeft
        , width fill
        ]
        [ Keyboard.view searchPreferences notationFacet language keyboardModel
            |> Element.map userInteractedWithKeyboardMsg
        ]
