module Page.Views.SourcePage.ExemplarsSection exposing (..)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, link, none, paddingXY, row, spacing, text, textColumn, width)
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Source exposing (ExemplarBody, ExemplarsSectionBody, ExternalResourceBody, ExternalResourcesListBody, FullSourceBody)
import Page.UI.Components exposing (h5, h6, label, viewSummaryField)
import Page.UI.Style exposing (colourScheme)


viewExemplarsRouter : FullSourceBody -> Language -> Element msg
viewExemplarsRouter body language =
    case body.exemplars of
        Just exemplarsSection ->
            viewExemplarsSection exemplarsSection language

        Nothing ->
            none


viewExemplarsSection : ExemplarsSectionBody -> Language -> Element msg
viewExemplarsSection exemplarSection language =
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
        summary =
            case exemplar.summary of
                Just sum ->
                    viewSummaryField sum language

                Nothing ->
                    none

        heldBy =
            row
                [ width fill
                , spacing 20
                ]
                [ viewHeldBy exemplar.heldBy language ]

        externalResources =
            case exemplar.externalResources of
                Just linksSection ->
                    viewExternalLinksSection linksSection language

                Nothing ->
                    none
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
            , summary
            , externalResources
            ]
        ]


viewHeldBy : BasicInstitutionBody -> Language -> Element msg
viewHeldBy body language =
    link
        [ Font.color colourScheme.lightBlue ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }


viewExternalLinksSection : ExternalResourcesListBody -> Language -> Element msg
viewExternalLinksSection linkSection language =
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
                        (List.map (\l -> viewExternalLink l language) linkSection.items)
                    )
                ]
            ]
        ]


viewExternalLink : ExternalResourceBody -> Language -> Element msg
viewExternalLink extLink language =
    link
        [ Font.color colourScheme.lightBlue ]
        { url = extLink.url
        , label = text (extractLabelFromLanguageMap language extLink.label)
        }
