module Page.UI.Record.ExemplarsSection exposing (viewBoundWithSection, viewExemplarExternalResourcesSection, viewExemplarsSection)

import Element exposing (Element, above, alignTop, column, el, fill, height, link, none, paragraph, px, row, spacing, spacingXY, text, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody)
import Page.RecordTypes.Holding exposing (BoundWithSectionBody, HoldingBody, HoldingType(..))
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Relationship exposing (RelatedTo(..), RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (ExemplarsSectionBody)
import Page.UI.Attributes exposing (bodyRegular, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (externalLinkTemplate, h3s, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalResources exposing (viewExternalRecords, viewExternalResources)
import Page.UI.Record.PageTemplate exposing (pageUriTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewExemplarsSection :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ExemplarsSectionBody
    -> Element msg
viewExemplarsSection { language, paragraphFormatter, preRenderedFormatter, relationshipFormatter, summaryFormatter } exemplarSection =
    List.map
        (viewExemplar
            { language = language
            , paragraphFormatter = paragraphFormatter
            , preRenderedFormatter = preRenderedFormatter
            , relationshipFormatter = relationshipFormatter
            , summaryFormatter = summaryFormatter
            }
        )
        exemplarSection.items
        |> sectionTemplate language exemplarSection


viewExemplar :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> HoldingBody
    -> Element msg
viewExemplar { language, paragraphFormatter, preRenderedFormatter, relationshipFormatter, summaryFormatter } exemplar =
    let
        pagelink =
            case exemplar.holdingType of
                ManuscriptHolding ->
                    none

                _ ->
                    viewSummaryField language
                        [ { label = localTranslations.exemplarURI
                          , value = toLanguageMap exemplar.id
                          }
                        ]
    in
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
                    [ viewMaybe (summaryFormatter language) exemplar.summary
                    , viewMaybe (paragraphFormatter language) exemplar.notes
                    , viewMaybe
                        (viewRelationshipsSection
                            { language = language
                            , relationshipFormatter = relationshipFormatter
                            }
                        )
                        exemplar.relationships
                    , viewMaybe
                        (viewBoundWithSection
                            { language = language
                            , relationshipFormatter = relationshipFormatter
                            }
                        )
                        exemplar.boundWith
                    , viewMaybe
                        (viewExemplarExternalResourcesSection
                            { language = language
                            , preRenderedFormatter = preRenderedFormatter
                            }
                        )
                        exemplar.externalResources
                    , pagelink
                    ]
                ]
            ]
        ]


viewBoundWithSection :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> BoundWithSectionBody
    -> Element msg
viewBoundWithSection { language, relationshipFormatter } boundWithSection =
    relationshipFormatter language
        boundWithSection.sectionLabel
        [ { role = Nothing
          , qualifier = Nothing
          , relatedTo =
                Just
                    { id = .id boundWithSection.source
                    , label = .label boundWithSection.source
                    , type_ = SourceRelationship
                    }
          , name = Nothing
          , note = Nothing
          }
        ]


viewHeldBy : Language -> BasicInstitutionBody -> Element msg
viewHeldBy language body =
    column
        [ width fill
        ]
        [ row
            [ width fill
            , spacingXY 10 5
            ]
            [ el
                [ width (px 20)
                , height (px 20)
                , alignTop
                , tooltip above
                    (el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.heldBy))
                    )
                ]
                (institutionSvg colourScheme.midGrey)
            , paragraph
                [ width fill ]
                [ link
                    [ linkColour
                    ]
                    { label = h3s language body.label
                    , url = body.id
                    }
                ]
            , externalLinkTemplate body.id
            ]
        ]


viewExemplarExternalResourcesSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> ExternalResourcesSectionBody
    -> Element msg
viewExemplarExternalResourcesSection { language, preRenderedFormatter } extSection =
    let
        externalResourcesList =
            Maybe.map (viewExternalResources language) extSection.items
                |> Maybe.map List.singleton
                |> Maybe.withDefault []

        externalRecordsList =
            Maybe.map (viewExternalRecords language) extSection.externalRecords
                |> Maybe.map List.singleton
                |> Maybe.withDefault []

        valuesList =
            List.concat [ externalResourcesList, externalRecordsList ]
    in
    preRenderedFormatter language
        [ { label = extSection.label
          , value = valuesList
          }
        ]
