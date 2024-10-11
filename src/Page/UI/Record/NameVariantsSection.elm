module Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Person exposing (NameVariantsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewNameVariantsSection : Language -> NameVariantsSectionBody -> Element msg
viewNameVariantsSection language variantsSection =
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
                [ viewSummaryField language variantsSection.items ]
            ]
        ]
