module Page.UI.Record.ExemplarsSection exposing (viewExemplar, viewExemplarRelationships, viewExemplarsSection, viewExternalResourcesSection, viewHeldBy)

import Element exposing (Element, above, alignTop, centerY, column, el, fill, height, link, px, row, shrink, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (ExemplarBody, ExemplarsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalResources exposing (viewExternalResource)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewExemplar : Language -> ExemplarBody -> Element msg
viewExemplar language exemplar =
    let
        heldBy =
            fieldValueWrapper
                [ wrappedRow
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        labelFieldColumnAttributes
                        [ renderLabel language exemplar.label ]
                    , column
                        valueFieldColumnAttributes
                        [ textColumn
                            [ spacing lineSpacing ]
                            [ viewHeldBy language exemplar.heldBy ]
                        ]
                    ]
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
            [ heldBy
            , viewMaybe (viewSummaryField language) exemplar.summary
            , viewMaybe (viewParagraphField language) exemplar.notes
            , viewMaybe (viewExternalResourcesSection language) exemplar.externalResources
            , viewMaybe (viewExemplarRelationships language) exemplar.relationships
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
            (List.map (\l -> viewRelationshipBody language l) body.items)
        ]


viewExemplarsSection : Language -> ExemplarsSectionBody -> Element msg
viewExemplarsSection language exemplarSection =
    List.map (\l -> viewExemplar language l) exemplarSection.items
        |> sectionTemplate language exemplarSection


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


viewHeldBy : Language -> BasicInstitutionBody -> Element msg
viewHeldBy language body =
    el
        [ width shrink ]
        (row
            [ width fill
            , spacing 5
            ]
            [ el
                [ width <| px 16
                , height <| px 16
                , centerY
                , tooltip above
                    (el
                        tooltipStyle
                        (text "Held by")
                    )
                ]
                (institutionSvg colourScheme.slateGrey)
            , link
                [ linkColour
                ]
                { label = text (extractLabelFromLanguageMap language body.label)
                , url = body.id
                }
            ]
        )
