module Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)

import Element exposing (Element, above, alignTop, centerY, column, el, fill, height, link, none, paragraph, px, row, shrink, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Relationship exposing (RelatedTo(..), RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel)
import Page.UI.Images exposing (institutionSvg, mapMarkerSvg, sourcesSvg, userCircleSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewRelatedToBody : Language -> RelatedToBody -> Element msg
viewRelatedToBody language body =
    let
        ( relIcon, relationshipTooltip ) =
            case body.type_ of
                PersonRelationship ->
                    ( userCircleSvg colourScheme.slateGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.person))
                    )

                InstitutionRelationship ->
                    ( institutionSvg colourScheme.slateGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.person))
                    )

                PlaceRelationship ->
                    ( mapMarkerSvg colourScheme.slateGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.place))
                    )

                SourceRelationship ->
                    ( sourcesSvg colourScheme.slateGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.source))
                    )

                UnknownRelationship ->
                    ( none, none )
    in
    el
        [ width shrink ]
        (row
            [ width fill
            , spacing 5
            ]
            [ el
                [ width (px 16)
                , height (px 16)
                , centerY
                , relationshipTooltip |> tooltip above
                ]
                relIcon
            , link
                [ linkColour ]
                { label = text (extractLabelFromLanguageMap language body.label)
                , url = body.id
                }
            ]
        )


viewRelationshipBody : Language -> RelationshipBody -> Element msg
viewRelationshipBody language body =
    let
        qualifierLabel =
            case body.qualifier of
                Just qual ->
                    el [] (text (" [" ++ extractLabelFromLanguageMap language qual.label ++ "]"))

                Nothing ->
                    none

        relatedToView =
            -- if there is a related-to relationship, display that.
            -- if all we have is a name, display that.
            -- if neither, don't show anything because we can't!
            case body.relatedTo of
                Just rel ->
                    if rel.type_ == PlaceRelationship then
                        el [] (text (extractLabelFromLanguageMap language rel.label))

                    else
                        viewRelatedToBody language rel

                Nothing ->
                    case body.name of
                        Just nm ->
                            el [] (text (extractLabelFromLanguageMap language nm))

                        Nothing ->
                            none

        roleLabel =
            case body.role of
                Just role ->
                    renderLabel language role.label

                Nothing ->
                    none

        note =
            case body.note of
                Just noteText ->
                    row
                        [ width fill ]
                        [ paragraph [] [ text (extractLabelFromLanguageMap language noteText) ] ]

                Nothing ->
                    none
    in
    fieldValueWrapper
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ roleLabel ]
            , column
                valueFieldColumnAttributes
                [ row
                    [ width fill ]
                    [ relatedToView
                    , qualifierLabel
                    ]
                , note
                ]
            ]
        ]


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionBody =
            [ row
                (width fill
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    (List.map (viewRelationshipBody language) relSection.items)
                ]
            ]
    in
    sectionTemplate language relSection sectionBody
