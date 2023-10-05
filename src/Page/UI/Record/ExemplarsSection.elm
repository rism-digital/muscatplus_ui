module Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)

import Element exposing (Element, above, alignTop, centerY, column, el, fill, height, link, paragraph, px, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (BoundWithSectionBody, ExemplarBody, ExemplarsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, h2, renderLabel, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg, sourcesSvg)
import Page.UI.Record.ExternalResources exposing (viewExternalRecords, viewExternalResources)
import Page.UI.Record.PageTemplate exposing (externalLinkTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewExemplar : Language -> ExemplarBody -> Element msg
viewExemplar language exemplar =
    row
        (width fill
            :: height fill
            :: alignTop
            :: spacing lineSpacing
            :: sectionBorderStyles
        )
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , spacing 5
                ]
                [ viewHeldBy language exemplar.heldBy ]
            , row
                [ width fill
                ]
                [ column
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ viewMaybe (viewSummaryField language) exemplar.summary
                    , viewMaybe (viewParagraphField language) exemplar.notes
                    , viewMaybe (viewExemplarRelationships language) exemplar.relationships
                    , viewMaybe (viewBoundWithSection language) exemplar.boundWith
                    , viewMaybe (viewExemplarExternalResourcesSection language) exemplar.externalResources
                    ]
                ]
            ]
        ]


viewExemplarRelationships : Language -> RelationshipsSectionBody -> Element msg
viewExemplarRelationships language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            (List.map (viewRelationshipBody language) body.items)
        ]


viewExemplarsSection : Language -> ExemplarsSectionBody -> Element msg
viewExemplarsSection language exemplarSection =
    List.map (viewExemplar language) exemplarSection.items
        |> sectionTemplate language exemplarSection


viewBoundWithSection : Language -> BoundWithSectionBody -> Element msg
viewBoundWithSection language boundWithSection =
    let
        relationshipTooltip =
            el
                tooltipStyle
                (text (extractLabelFromLanguageMap language localTranslations.source))
    in
    fieldValueWrapper []
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language boundWithSection.sectionLabel ]
            , column
                valueFieldColumnAttributes
                [ row
                    [ width fill
                    , spacing 5
                    ]
                    [ el
                        [ width (px 16)
                        , height (px 16)
                        , centerY
                        , relationshipTooltip |> tooltip above
                        ]
                        (sourcesSvg colourScheme.slateGrey)
                    , link
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap language (.label boundWithSection.source))
                        , url = .id boundWithSection.source
                        }
                    ]
                ]
            ]
        ]


viewHeldBy : Language -> BasicInstitutionBody -> Element msg
viewHeldBy language body =
    column
        [ width fill
        ]
        [ row
            [ width fill
            , spacing 5
            ]
            [ el
                [ width (px 25)
                , height (px 25)
                , tooltip above
                    (el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.heldBy))
                    )
                ]
                (institutionSvg colourScheme.slateGrey)
            , paragraph
                [ width fill ]
                [ link
                    [ linkColour
                    ]
                    { label = h2 language body.label
                    , url = body.id
                    }
                ]
            , externalLinkTemplate body.id
            ]
        ]


viewExemplarExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExemplarExternalResourcesSection language extSection =
    fieldValueWrapper []
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language extSection.label ]
            , column
                valueFieldColumnAttributes
                [ viewMaybe (viewExternalResources language) extSection.items
                , viewMaybe (viewExternalRecords language) extSection.externalRecords
                ]
            ]
        ]
