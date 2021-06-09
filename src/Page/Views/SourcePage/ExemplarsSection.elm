module Page.Views.SourcePage.ExemplarsSection exposing (..)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, htmlAttribute, link, paddingXY, row, spacing, text, textColumn, width)
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Source exposing (ExemplarBody, ExemplarsSectionBody)
import Page.UI.Components exposing (h5, label, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Helpers exposing (viewMaybe)


viewExemplarsSection : Language -> ExemplarsSectionBody -> Element msg
viewExemplarsSection language exemplarSection =
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
                , htmlAttribute (HTA.id exemplarSection.sectionToc)
                ]
                [ h5 language exemplarSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                (List.map (\l -> viewExemplar l language) exemplarSection.items)
            ]
        ]


viewExemplar : ExemplarBody -> Language -> Element msg
viewExemplar exemplar language =
    let
        heldBy =
            row
                [ width fill
                , spacing 20
                ]
                [ viewHeldBy language exemplar.heldBy ]
    in
    row
        [ width fill
        , Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }
        , Border.color colourScheme.midGrey
        , paddingXY 10 0
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
            ]
            [ heldBy
            , viewMaybe (viewSummaryField language) exemplar.summary
            , viewMaybe (viewExternalResourcesSection language) exemplar.externalResources
            ]
        ]


viewHeldBy : Language -> BasicInstitutionBody -> Element msg
viewHeldBy language body =
    link
        [ Font.color colourScheme.lightBlue ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language linkSection =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , spacing 10
            ]
            [ row
                [ width fill
                , paddingXY 0 10
                ]
                [ el
                    [ width (fillPortion 1)
                    , alignTop
                    ]
                    (label language linkSection.label)
                , el
                    [ width (fillPortion 4)
                    , alignTop
                    ]
                    (textColumn
                        []
                        (List.map (\l -> viewExternalResource language l) linkSection.items)
                    )
                ]
            ]
        ]


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language extLink =
    link
        [ Font.color colourScheme.lightBlue ]
        { url = extLink.url
        , label = text (extractLabelFromLanguageMap language extLink.label)
        }
