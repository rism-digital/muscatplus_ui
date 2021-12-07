module Page.Record.Views.ExternalResources exposing (..)

import Element exposing (Element, column, fill, link, paragraph, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, widthFillHeightFill)


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
    row
        [ width fill ]
        [ paragraph
            []
            [ link
                [ linkColour ]
                { url = body.url
                , label = text (extractLabelFromLanguageMap language body.label)
                }
            ]
        ]
