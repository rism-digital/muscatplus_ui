module Page.Record.Views.ExternalResources exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, paragraph, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes, widthFillHeightFill)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel)


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language extSection =
    let
        sectionBody =
            [ row
                (List.concat [ widthFillHeightFill, sectionBorderStyles ])
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    (List.map (\l -> viewExternalResource language l) extSection.items)
                ]
            ]
    in
    sectionTemplate language extSection sectionBody


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language body =
    fieldValueWrapper <|
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language body.label ]
            , column
                valueFieldColumnAttributes
                [ row
                    [ width fill ]
                    [ link
                        [ linkColour ]
                        { url = body.url
                        , label = text body.url
                        }
                    ]
                ]
            ]
        ]
