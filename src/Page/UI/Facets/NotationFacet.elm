module Page.UI.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)

import Element exposing (Element)
import Language exposing (Language, LanguageMap)
import Page.Keyboard as Keyboard
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Keyboard.Views as Keyboard
import Page.RecordTypes.Search exposing (NotationFacet)
import SearchPreferences exposing (SearchPreferences)


type alias NotationFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
    , keyboardModel : Keyboard.Model KeyboardMsg
    , notationFacet : NotationFacet
    , userInteractedWithKeyboardMsg : KeyboardMsg -> msg
    , searchPreferences : Maybe SearchPreferences
    , suppressKeyboardGraphic : Bool
    }


viewKeyboardControl : NotationFacetConfig msg -> Element msg
viewKeyboardControl { language, keyboardModel, notationFacet, userInteractedWithKeyboardMsg, searchPreferences, suppressKeyboardGraphic } =
    Keyboard.view
        { language = language
        , model = keyboardModel
        , notationFacet = notationFacet
        , searchPreferences = searchPreferences
        , suppressKeyboardGraphic = suppressKeyboardGraphic
        }
        |> Element.map userInteractedWithKeyboardMsg
