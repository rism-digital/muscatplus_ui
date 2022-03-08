module Page.Record.Views.SourcePage.SourceItemsSection exposing (..)

import Element exposing (Element, column, fill, link, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (headingMD, headingSM, lineSpacing, linkColour, sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)


viewSourceItemsSection : Language -> SourceItemsSectionBody -> Element msg
viewSourceItemsSection language siSection =
    List.map (\sourceBody -> viewSourceItem language sourceBody) siSection.items
        |> sectionTemplate language siSection


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
                    , headingMD
                    ]
                    { url = source.id
                    , label = text (extractLabelFromLanguageMap language source.label)
                    }
                ]
            , Maybe.withDefault [] source.summary
                |> viewSummaryField language
            ]
        ]
