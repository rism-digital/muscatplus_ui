module Page.Record.Views.SourcePage.SourceItemsSection exposing (..)

import Element exposing (Element, column, fill, link, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.Record.Views.SourcePage.ContentsSection exposing (viewContentsSection, viewMinimalContentsSection)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (headingSM, lineSpacing, linkColour, sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


viewSourceItemsSection : Language -> SourceItemsSectionBody -> Element msg
viewSourceItemsSection language siSection =
    sectionTemplate language siSection (List.map (\sourceBody -> viewSourceItem language sourceBody) siSection.items)


viewSourceItem : Language -> BasicSourceBody -> Element msg
viewSourceItem language source =
    let
        contents =
            source.contents
    in
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
            , viewMaybe (viewMinimalContentsSection language) source.contents
            ]
        ]
