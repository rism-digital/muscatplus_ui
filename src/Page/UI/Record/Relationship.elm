module Page.UI.Record.Relationship exposing (gatherRelationshipItems, viewMobileRelationshipBody, viewRelatedToBody, viewRelationshipBody, viewRelationshipsSection)

import Dict
import Dict.Extra as DE
import Element exposing (Element, above, alignLeft, alignTop, column, el, fill, height, link, none, paddingXY, paragraph, px, row, spacing, text, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.RecordTypes.Relationship exposing (QualifierBody, RelatedTo(..), RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour)
import Page.UI.Components exposing (viewPreRenderedLabelValueField, viewPreRenderedMobileLabelValueField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (folderMusicSvg, institutionSvg, mapMarkerSvg, sourcesSvg, userCircleSvg, userMusicSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewRelationshipsSection :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> RelationshipsSectionBody
    -> Element msg
viewRelationshipsSection { language, relationshipFormatter } relSection =
    sectionTemplate language
        relSection
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
                    |> List.map (\( label, items ) -> relationshipFormatter language label items)
                )
            ]
        ]


viewRelationshipBody : Language -> LanguageMap -> List RelationshipBody -> Element msg
viewRelationshipBody language label relationships =
    viewPreRenderedLabelValueField [ spacing lineSpacing ]
        language
        [ { label = label
          , value = List.map (viewRelationshipValue language) relationships
          }
        ]


viewMobileRelationshipBody : Language -> LanguageMap -> List RelationshipBody -> Element msg
viewMobileRelationshipBody language label relationships =
    viewPreRenderedMobileLabelValueField
        [ spacing 4 ]
        language
        [ { label = label
          , value = List.map (viewRelationshipValue language) relationships
          }
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
                    viewMaybe
                        (\nm ->
                            row
                                [ width fill ]
                                [ paragraph [] [ text (extractLabelFromLanguageMap language nm) ] ]
                        )
                        body.name
                )
                (viewRelatedToBody language body.qualifier)
                body.relatedTo

        note =
            viewMaybe
                (\noteText ->
                    row
                        [ width fill
                        , paddingXY 20 0
                        ]
                        [ paragraph
                            [ width fill ]
                            [ text (extractLabelFromLanguageMap language noteText) ]
                        ]
                )
                body.note
    in
    row
        [ alignLeft
        , width fill
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ relatedToView
            , note
            ]
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

                WorkRelationship ->
                    ( userMusicSvg colourScheme.midGrey
                    , el tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.works))
                    )

                PublicationRelationship ->
                    ( folderMusicSvg colourScheme.midGrey
                    , el tooltipStyle
                        (text (extractLabelFromLanguageMap language localTranslations.workCatalogues))
                    )

                UnknownRelationship ->
                    ( none, none )

        linkRelated : LanguageMap -> Element msg
        linkRelated label =
            link
                [ linkColour
                , height fill
                , alignTop
                ]
                { label = paragraph [ alignTop, height fill ] [ text (extractLabelFromLanguageMap language label) ]
                , url = body.id
                }

        relatedEntity =
            case body.type_ of
                PersonRelationship ->
                    linkRelated body.label

                InstitutionRelationship ->
                    linkRelated body.label

                PlaceRelationship ->
                    el
                        [ height fill, width fill, alignTop ]
                        (paragraph [ alignTop, height fill ] [ text (extractLabelFromLanguageMap language body.label) ])

                SourceRelationship ->
                    linkRelated body.label

                WorkRelationship ->
                    linkRelated body.label

                PublicationRelationship ->
                    linkRelated body.label

                UnknownRelationship ->
                    none

        qualifierLabel =
            viewMaybe
                (\qual ->
                    paragraph [ alignTop, height fill ] [ text (" [" ++ extractLabelFromLanguageMap language qual.label ++ "]") ]
                )
                qualifier
    in
    row
        [ height fill
        , width fill
        , spacing 5
        ]
        [ el [ width (px 14) ]
            (el
                [ width fill
                , relationshipTooltip |> tooltip above
                ]
                relIcon
            )
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

        relationshipTypeSortOrder : List RelationshipBody -> Int
        relationshipTypeSortOrder lrels =
            case List.head lrels |> Maybe.andThen .relatedTo |> Maybe.map .type_ of
                Just PersonRelationship ->
                    0

                Just InstitutionRelationship ->
                    1

                Just PlaceRelationship ->
                    2

                Just SourceRelationship ->
                    3

                Just WorkRelationship ->
                    4

                Just PublicationRelationship ->
                    6

                Just UnknownRelationship ->
                    5

                Nothing ->
                    7
    in
    DE.groupBy (\i -> Maybe.map (\j -> j.value) i.role |> Maybe.withDefault "") rels
        |> Dict.toList
        |> List.sortBy (\( roleValue, rl ) -> ( relationshipTypeSortOrder rl, roleValue ))
        |> List.map (\( _, rl ) -> ( helper rl, rl ))
