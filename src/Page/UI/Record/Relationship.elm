module Page.UI.Record.Relationship exposing (viewRelatedToBody, viewRelationshipBody, viewRelationshipsSection)

import Element exposing (Element, above, alignLeft, alignTop, centerY, column, el, fill, height, link, none, paragraph, px, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.RecordTypes.Relationship exposing (QualifierBody, RelatedTo(..), RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Attributes exposing (bodyRegular, labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg, mapMarkerSvg, sourcesSvg, userCircleSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Utilities exposing (choose)


viewRelatedToBody : Language -> Maybe QualifierBody -> RelatedToBody -> Element msg
viewRelatedToBody language qualifier body =
    let
        ( relIcon, relationshipTooltip ) =
            case body.type_ of
                PersonRelationship ->
                    ( userCircleSvg colourScheme.midGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.person))
                    )

                InstitutionRelationship ->
                    ( institutionSvg colourScheme.midGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.institution))
                    )

                PlaceRelationship ->
                    ( mapMarkerSvg colourScheme.midGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.place))
                    )

                SourceRelationship ->
                    ( sourcesSvg colourScheme.midGrey
                    , el
                        tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.source))
                    )

                UnknownRelationship ->
                    ( none, none )

        qualifierLabel =
            viewMaybe
                (\qual ->
                    el [] (text (" [" ++ extractLabelFromLanguageMap language qual.label ++ "]"))
                )
                qualifier
    in
    row
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
        , qualifierLabel
        ]


viewRelationshipBody : Language -> RelationshipBody -> Element msg
viewRelationshipBody language body =
    let
        relatedToView =
            -- if there is a related-to relationship, display that.
            -- if all we have is a name, display that.
            -- if neither, don't show anything because we can't!
            ME.unpack
                (\() ->
                    viewMaybe (\nm -> el [] (text (extractLabelFromLanguageMap language nm))) body.name
                )
                (\rel ->
                    choose (rel.type_ == PlaceRelationship)
                        (\() -> el [] (text (extractLabelFromLanguageMap language rel.label)))
                        (\() -> viewRelatedToBody language body.qualifier rel)
                )
                body.relatedTo

        roleLabel =
            viewMaybe (\role -> renderLabel language role.label) body.role

        note =
            viewMaybe
                (\noteText ->
                    row
                        [ width fill ]
                        [ paragraph [] [ text (extractLabelFromLanguageMap language noteText) ] ]
                )
                body.note
    in
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            labelFieldColumnAttributes
            [ roleLabel ]
        , column
            valueFieldColumnAttributes
            [ textColumn
                [ alignLeft
                , bodyRegular
                ]
                [ relatedToView
                , note
                ]
            ]
        ]


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionTmpl =
            sectionTemplate language relSection
    in
    sectionTmpl
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
