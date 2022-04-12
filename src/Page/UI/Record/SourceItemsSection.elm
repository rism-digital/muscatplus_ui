module Page.UI.Record.SourceItemsSection exposing (..)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, link, px, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (headingMD, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)


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
                [ width fill
                , spacing 5
                ]
                [ el
                    [ width <| px 20
                    , height <| px 20
                    , centerY
                    ]
                    (sourcesSvg colourScheme.slateGrey)
                , link
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
