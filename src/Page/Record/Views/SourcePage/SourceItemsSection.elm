module Page.Record.Views.SourcePage.SourceItemsSection exposing (..)

import Element exposing (Element, column, fill, height, link, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (headingSM, headingXS, lineSpacing, linkColour, sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.SectionTemplate exposing (sectionTemplate)


viewSourceItemsSection : Language -> SourceItemsSectionBody -> Element msg
viewSourceItemsSection language siSection =
    sectionTemplate language siSection (List.map (\sourceBody -> viewSourceItem language sourceBody) siSection.items)


viewSourceItem : Language -> BasicSourceBody -> Element msg
viewSourceItem language source =
    row
        (List.append [ width fill ] sectionBorderStyles)
        [ column
            (List.append [ spacing lineSpacing ] widthFillHeightFill)
            [ row
                [ width fill ]
                [ link
                    [ linkColour
                    , headingSM
                    ]
                    { url = source.id, label = text (extractLabelFromLanguageMap language source.label) }
                ]
            , viewMaybe (viewSummaryField language) source.summary
            ]
        ]
