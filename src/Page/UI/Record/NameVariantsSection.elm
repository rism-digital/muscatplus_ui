module Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Person exposing (NameVariantsSectionBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewNameVariantsSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> NameVariantsSectionBody
    -> Element msg
viewNameVariantsSection { language, summaryFormatter } variantsSection =
    sectionTemplate
        language
        variantsSection
        [ row
            (width fill
                :: height fill
                :: alignTop
                :: sectionBorderStyles
            )
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                [ summaryFormatter language variantsSection.items ]
            ]
        ]
