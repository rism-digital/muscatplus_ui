module Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)

import Element exposing (Element, above, alignTop, column, el, fill, height, link, px, row, spacing, text, textColumn, width, wrappedRow)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (ExemplarBody, ExemplarsSectionBody)
import Page.UI.Attributes exposing (headingLG, labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
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
                [ width fill ]
                [ column
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ viewMaybe (viewSummaryField language) exemplar.summary
                    , viewMaybe (viewParagraphField language) exemplar.notes
                    , viewMaybe (viewExternalResourcesSection language) exemplar.externalResources
                    , viewMaybe (viewExemplarRelationships language) exemplar.relationships
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
                    (List.map (viewExternalResource language) linkSection.items)
                ]
            ]
        ]


viewHeldBy : Language -> BasicInstitutionBody -> Element msg
viewHeldBy language body =
    row
        [ width fill
        , spacing 5
        ]
        [ el
            [ width (px 20)
            , height (px 20)
            , tooltip above
                (el
                    tooltipStyle
                    (text (extractLabelFromLanguageMap language localTranslations.heldBy))
                )
            ]
            (institutionSvg colourScheme.slateGrey)
        , link
            [ linkColour
            , headingLG
            , Font.medium
            ]
            { label = text (extractLabelFromLanguageMap language body.label)
            , url = body.id
            }
        ]
