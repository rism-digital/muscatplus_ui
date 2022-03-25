module Page.Record.Views.ExternalResources exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, row, spacing, text, width, wrappedRow)
import Language exposing (Language)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (renderParagraph)


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language extSection =
    let
        sectionBody =
            [ row
                ([ width fill
                 , height fill
                 , alignTop
                 ]
                    ++ sectionBorderStyles
                )
                [ column
                    [ spacing sectionSpacing
                    , width fill
                    , height fill
                    , alignTop
                    ]
                    (List.map (\l -> viewExternalResource language l) extSection.items)
                ]
            ]
    in
    sectionTemplate language extSection sectionBody


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language body =
    wrappedRow
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ renderParagraph language body.label ]
            , row
                [ width fill ]
                [ link
                    [ linkColour ]
                    { url = body.url
                    , label = text body.url
                    }
                ]
            ]
        ]
