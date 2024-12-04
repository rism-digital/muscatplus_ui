module Mobile.Record.SourcePage exposing (viewFullMobileSourcePage)

import Dict
import Element exposing (Element, alignTop, clipY, column, el, fill, height, htmlAttribute, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (sourceIconChooser, viewMobileParagraphField, viewMobileSummaryField)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewSourceWorksSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobileSourcePage :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewFullMobileSourcePage session model body =
    let
        sourceIcon =
            .recordType body.sourceTypes
                |> .type_
                |> sourceIconChooser

        sourceIconView =
            el
                [ width (px 25)
                , height (px 25)
                , alignTop
                ]
                (sourceIcon colourScheme.darkBlue)

        allExternals =
            gatherAllDigitizationLinksForCallout session.language body
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ row
                [ width fill
                , paddingXY 10 10
                , Border.widthEach { bottom = 4, left = 0, right = 0, top = 0 }
                , htmlAttribute (HA.style "border-bottom-style" "double")
                , Border.color colourScheme.midGrey
                ]
                [ mobilePageHeaderTemplate session.language (Just sourceIconView) body ]
            , row
                [ width fill
                , height fill
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , padding 20
                    , spacing sectionSpacing
                    ]
                    [ viewMaybe (viewPartOfSection session.language) body.partOf
                    , viewIf
                        (viewDigitizedCopiesCalloutSection
                            { expandMsg = RecordMsg.UserClickedExpandDigitalCopiesCallout
                            , expanded = model.digitizedCopiesCalloutExpanded
                            , language = session.language
                            }
                            allExternals
                        )
                        (not (Dict.isEmpty allExternals))
                    , viewMaybe
                        (viewContentsSection
                            { creator = body.creator
                            , language = session.language
                            , relationshipFormatter = viewMobileRelationshipBody
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.contents
                    , viewMaybe
                        (viewIncipitsSection
                            { language = session.language
                            , infoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                            , expandedIncipits = model.incipitInfoExpanded
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.incipits
                    , viewMaybe
                        (viewMaterialGroupsSection
                            { language = session.language
                            , paragraphFormatter = viewMobileParagraphField
                            , relationshipFormatter = viewMobileRelationshipBody
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.materialGroups
                    , viewMaybe
                        (viewRelationshipsSection
                            { language = session.language
                            , relationshipFormatter = viewMobileRelationshipBody
                            }
                        )
                        body.relationships
                    , viewMaybe (viewSourceWorksSection session.language) body.works
                    , viewMaybe
                        (viewReferencesNotesSection
                            { language = session.language
                            , paragraphFormatter = viewMobileParagraphField
                            }
                        )
                        body.referencesNotes
                    , viewMaybe (viewExternalResourcesSection session.language) body.externalResources
                    , viewMaybe
                        (viewExemplarsSection
                            { language = session.language
                            , paragraphFormatter = viewMobileParagraphField
                            , relationshipFormatter = viewMobileRelationshipBody
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.exemplars
                    , viewMaybe (viewDigitalObjectsSection session.language) body.digitalObjects
                    ]
                ]
            ]
        ]
