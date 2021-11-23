module Page.Record.Views.SourcePage.SourceItemsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, link, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (headingXS, linkColour)
import Page.UI.Components exposing (h5, viewSummaryField)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.Helpers exposing (viewMaybe)


viewSourceItemsSection : Language -> SourceItemsSectionBody -> Element msg
viewSourceItemsSection language siSection =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill
                , htmlAttribute (HTA.id siSection.sectionToc)
                ]
                [ h5 language siSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                (List.map (\l -> viewSourceItem language l) siSection.items)
            ]
        ]


viewSourceItem : Language -> BasicSourceBody -> Element msg
viewSourceItem language source =
    row
        [ width fill
        , Border.widthEach { left = 2, right = 0, bottom = 0, top = 0 }
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , paddingXY 10 0
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
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
