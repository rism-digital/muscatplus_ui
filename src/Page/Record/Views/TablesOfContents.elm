module Page.Record.Views.TablesOfContents exposing (..)

import Element exposing (Element, el, fill, pointer, row, text, width)
import Element.Events exposing (onClick)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.UI.Attributes exposing (linkColour)


createSectionLink : Language -> { a | label : LanguageMap, sectionToc : String } -> Element RecordMsg
createSectionLink language section =
    createTocLink language section.label (UserClickedToCItem section.sectionToc)


createTocLink : Language -> LanguageMap -> msg -> Element msg
createTocLink language label onClickMsg =
    -- TODO: Scrolling probably needs to be implemented with
    -- https://package.elm-lang.org/packages/elm/browser/latest/Browser.Dom
    row
        [ width fill
        ]
        [ el
            [ linkColour
            , onClick onClickMsg
            , pointer
            ]
            (text (extractLabelFromLanguageMap language label))
        ]
