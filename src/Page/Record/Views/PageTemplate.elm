module Page.Record.Views.PageTemplate exposing (..)

import Element exposing (Element, alignBottom, alignRight, column, el, fill, htmlAttribute, link, row, text, width)
import Html.Attributes as HTA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Views.RecordHistory exposing (viewRecordHistory)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.UI.Attributes exposing (headingLG, linkColour)
import Page.UI.Components exposing (h1)


pageHeaderTemplate : Language -> { a | sectionToc : String, label : LanguageMap } -> Element msg
pageHeaderTemplate language header =
    row
        [ width fill
        , htmlAttribute (HTA.id header.sectionToc)
        ]
        [ h1 language header.label ]


pageUriTemplate : Language -> { a | id : String } -> Element msg
pageUriTemplate language body =
    row
        [ width fill ]
        [ el
            [ headingLG
            ]
            (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
        , link
            [ linkColour ]
            { url = body.id
            , label = el [ headingLG ] (text body.id)
            }
        ]


pageFooterTemplate : Language -> { a | recordHistory : RecordHistory } -> Element msg
pageFooterTemplate language footer =
    row
        [ width fill
        , alignBottom
        ]
        [ column
            [ width fill
            , alignRight
            ]
            [ viewRecordHistory language footer.recordHistory
            ]
        ]
