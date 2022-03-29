module Page.Record.Views.SourcePage.SourceItemsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (headingMD, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)


viewSourceItemsSection : Language -> SourceItemsSectionBody -> Element msg
viewSourceItemsSection language siSection =
    List.map (\sourceBody -> viewSourceItem language sourceBody) siSection.items
        |> sectionTemplate language siSection


viewSourceItem : Language -> BasicSourceBody -> Element msg
viewSourceItem language source =
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
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
