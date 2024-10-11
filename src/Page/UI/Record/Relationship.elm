module Page.UI.Record.Relationship exposing (gatherRelationshipItems, viewMobileRelationshipBody, viewRelatedToBody, viewRelationshipBody, viewRelationshipsSection)

import Dict
import Dict.Extra as DE
import Element exposing (Element, alignLeft, alignTop, below, centerY, column, el, fill, height, link, none, paddingXY, paragraph, px, row, spacing, text, width, wrappedRow)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.RecordTypes.Relationship exposing (QualifierBody, RelatedTo(..), RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, valueFieldColumnAttributes)
import Page.UI.Components exposing (renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg, mapMarkerSvg, sourcesSvg, userCircleSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionTmpl =
            sectionTemplate language relSection
    in
    sectionTmpl
        [ row
            [ width fill
            , height fill
            , alignTop
            , paddingXY lineSpacing 0
            ]
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                (gatherRelationshipItems relSection.items
                    |> List.map (\( label, items ) -> viewRelationshipBody language label items)
                )
            ]
        ]


viewRelationshipBody : Language -> LanguageMap -> List RelationshipBody -> Element msg
viewRelationshipBody language label relationships =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column labelFieldColumnAttributes
            [ renderLabel language label ]
        , List.map (viewRelationshipValue language) relationships
            |> column valueFieldColumnAttributes
        ]


viewMobileRelationshipBody : Language -> LanguageMap -> List RelationshipBody -> Element msg
viewMobileRelationshipBody language label relationships =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , spacing 4
            ]
            (row [ width fill ] [ renderLabel language label ]
                :: List.map (viewRelationshipValue language) relationships
            )
        ]


viewRelationshipValue : Language -> RelationshipBody -> Element msg
viewRelationshipValue language body =
    let
        relatedToView =
            -- if there is a related-to relationship, display that.
            -- if all we have is a name, display that.
            -- if neither, don't show anything because we can't!
            ME.unpack
                (\() ->
                    viewMaybe (\nm -> row [ width fill ] [ text (extractLabelFromLanguageMap language nm) ]) body.name
                )
                (viewRelatedToBody language body.qualifier)
                body.relatedTo

        note =
            viewMaybe
                (\noteText ->
                    row
                        [ width fill ]
                        [ paragraph [] [ text (extractLabelFromLanguageMap language noteText) ] ]
                )
                body.note
    in
    row
        [ alignLeft
        ]
        [ relatedToView
        , note
        ]


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

        linkRelated : LanguageMap -> Element msg
        linkRelated label =
            link
                [ linkColour
                , centerY
                ]
                { label = text (extractLabelFromLanguageMap language label)
                , url = body.id
                }

        relatedEntity =
            case body.type_ of
                PersonRelationship ->
                    linkRelated body.label

                InstitutionRelationship ->
                    linkRelated body.label

                PlaceRelationship ->
                    el [ centerY ] (text (extractLabelFromLanguageMap language body.label))

                SourceRelationship ->
                    linkRelated body.label

                UnknownRelationship ->
                    none

        qualifierLabel =
            viewMaybe
                (\qual ->
                    el [ centerY ] (text (" [" ++ extractLabelFromLanguageMap language qual.label ++ "]"))
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
            , relationshipTooltip |> tooltip below
            ]
            relIcon
        , relatedEntity
        , qualifierLabel
        ]



-- Takes a list of relationships and gathers them by their relationship type, ("rtype", [list of relationships]).
-- It then substitutes the label LanguageMap for the first value in the Tuple, so that all
-- the relationships can be displayed


gatherRelationshipItems : List RelationshipBody -> List ( LanguageMap, List RelationshipBody )
gatherRelationshipItems rels =
    let
        helper : List RelationshipBody -> LanguageMap
        helper lrels =
            List.head lrels
                |> Maybe.andThen (\a -> a.role)
                |> Maybe.map (\b -> b.label)
                |> Maybe.withDefault (toLanguageMap "[No Role]")
    in
    DE.groupBy (\i -> Maybe.map (\j -> j.value) i.role |> Maybe.withDefault "") rels
        |> Dict.toList
        |> List.map (\( _, rl ) -> ( helper rl, rl ))
