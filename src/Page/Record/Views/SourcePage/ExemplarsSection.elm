module Page.Record.Views.SourcePage.ExemplarsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (ExemplarBody, ExemplarsSectionBody)
import Page.UI.Attributes exposing (headingMD, labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing, valueFieldColumnAttributes, widthFillHeightFill)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


viewExemplarsSection : Language -> ExemplarsSectionBody -> Element msg
viewExemplarsSection language exemplarSection =
    sectionTemplate language exemplarSection (List.map (\l -> viewExemplar language l) exemplarSection.items)


viewExemplar : Language -> ExemplarBody -> Element msg
viewExemplar language exemplar =
    let
        heldBy =
            row
                (List.append [ spacing lineSpacing ] widthFillHeightFill)
                [ viewHeldBy language exemplar.heldBy ]
    in
    row
        (List.concat [ widthFillHeightFill, sectionBorderStyles ])
        [ column
            (List.append [ spacing lineSpacing ] widthFillHeightFill)
            [ heldBy
            , viewMaybe (viewSummaryField language) exemplar.summary
            , viewMaybe (viewParagraphField language) exemplar.notes
            , viewMaybe (viewExternalResourcesSection language) exemplar.externalResources
            , viewMaybe (viewExemplarRelationships language) exemplar.relationships
            ]
        ]


viewHeldBy : Language -> BasicInstitutionBody -> Element msg
viewHeldBy language body =
    link
        [ linkColour
        , headingMD
        ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language linkSection =
    fieldValueWrapper
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language linkSection.label ]
            , column
                valueFieldColumnAttributes
                [ textColumn
                    [ spacing lineSpacing ]
                    (List.map (\l -> viewExternalResource language l) linkSection.items)
                ]
            ]
        ]


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language extLink =
    link
        [ linkColour ]
        { url = extLink.url
        , label = text (extractLabelFromLanguageMap language extLink.label)
        }


viewExemplarRelationships : Language -> RelationshipsSectionBody -> Element msg
viewExemplarRelationships language body =
    row
        widthFillHeightFill
        [ column
            (List.append [ spacing lineSpacing ] widthFillHeightFill)
            (List.map (\l -> viewRelationshipBody language l) body.items)
        ]
