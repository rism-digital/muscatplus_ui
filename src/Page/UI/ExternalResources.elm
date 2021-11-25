module Page.UI.ExternalResources exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, link, paddingXY, paragraph, row, spacing, text, width)
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h5)


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language extSection =
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
                , htmlAttribute (HTA.id extSection.sectionToc)
                ]
                [ h5 language extSection.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing 15
                    ]
                    (List.map (\l -> viewExternalResource language l) extSection.items)
                ]
            ]
        ]


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
