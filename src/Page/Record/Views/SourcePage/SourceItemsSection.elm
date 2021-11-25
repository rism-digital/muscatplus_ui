module Page.Record.Views.SourcePage.SourceItemsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (headingXS, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewSourceItemsSection : Language -> SourceItemsSectionBody -> Element msg
viewSourceItemsSection language siSection =
    let
        sectionBody =
            List.map (\sourceBody -> viewSourceItem language sourceBody) siSection.items
    in
    sectionTemplate language siSection sectionBody


viewSourceItem : Language -> BasicSourceBody -> Element msg
viewSourceItem language source =
    row
        (List.append [ width fill ] sectionBorderStyles)
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill ]
                [ link
                    [ linkColour
                    , headingXS
                    , Font.semiBold
                    ]
                    { url = source.id, label = text (extractLabelFromLanguageMap language source.label) }
                ]
            , viewMaybe (viewSummaryField language) source.summary
            ]
        ]
