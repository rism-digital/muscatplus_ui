module Page.Views.ExternalResources exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, link, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.UI.Components exposing (h5)
import Page.UI.Style exposing (colourScheme)


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
                    , spacing 10
                    ]
                    (List.map (\l -> viewExternalResource language l) extSection.items)
                ]
            ]
        ]


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language body =
    row
        [ width fill ]
        [ link
            [ Font.color colourScheme.lightBlue ]
            { url = body.url
            , label = text (extractLabelFromLanguageMap language body.label)
            }
        ]