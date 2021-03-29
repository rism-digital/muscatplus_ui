module Records.Views.Person exposing (..)

import Api.Records exposing (ExternalResource, ExternalResourceList, LabelValue, NoteList, PersonBody, PersonNameVariantList, PersonRelation, PersonRelationList, RelatedEntity, Relationship, SeeAlso)
import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, link, none, paddingEach, paddingXY, paragraph, px, row, spacing, spacingXY, text, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Msg)
import Records.Views.Shared exposing (viewSummaryField)
import UI.Components exposing (h2, h4, label, styledLink, value)
import UI.Style exposing (bodyRegular)


viewPersonRecord : PersonBody -> Language -> Element Msg
viewPersonRecord body language =
    row
        [ alignTop
        , width fill
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , height (px 120)
                ]
                [ h2 language body.label ]
            , row
                [ width fill
                , height fill
                ]
                [ column
                    [ width fill
                    , spacing 20
                    ]
                    (List.map (\viewSection -> viewSection body language)
                        [ viewBiographySection
                        , viewNameVariantsSection
                        , viewRelationsSection
                        , viewReferencesNotesSection
                        , viewExternalResourcesSectionSection
                        , viewExternalAuthoritiesSection
                        ]
                    )
                ]
            ]
        ]


{-|

    Main entry fields

-}
viewBiographySection : PersonBody -> Language -> Element Msg
viewBiographySection body language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ viewSummaryField body.summary language ]
        ]


{-|

    External authorities section

-}
viewExternalAuthoritiesSection : PersonBody -> Language -> Element Msg
viewExternalAuthoritiesSection body language =
    case body.seeAlso of
        Just extAuthList ->
            viewExternalAuthorities extAuthList language

        Nothing ->
            none


viewExternalAuthorities : List SeeAlso -> Language -> Element Msg
viewExternalAuthorities seeAlsoList language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            (List.map (\it -> viewExternalAuthority it language) seeAlsoList)
        ]


viewExternalAuthority : SeeAlso -> Language -> Element Msg
viewExternalAuthority seeAlso language =
    row
        [ width fill
        ]
        [ el
            [ width fill
            , spacingXY 0 10
            ]
            (styledLink seeAlso.url (extractLabelFromLanguageMap language seeAlso.label))
        ]


viewNameVariantsSection : PersonBody -> Language -> Element Msg
viewNameVariantsSection body language =
    case body.nameVariants of
        Just variants ->
            viewNameVariants variants language

        Nothing ->
            none


viewNameVariants : PersonNameVariantList -> Language -> Element Msg
viewNameVariants variants language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ h4 language variants.label ]
            , viewSummaryField variants.items language
            ]
        ]


viewRelationsSection : PersonBody -> Language -> Element Msg
viewRelationsSection body language =
    case body.relations of
        Just relationships ->
            viewRelations relationships language

        Nothing ->
            none


viewRelations : PersonRelationList -> Language -> Element Msg
viewRelations relationships language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ h4 language relationships.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\r -> viewRelationTypes r language) relationships.items)
                ]
            ]
        ]


viewRelationTypes : PersonRelation -> Language -> Element Msg
viewRelationTypes relation language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width (fillPortion 2), alignTop ]
            [ label language relation.label ]
        , column
            [ width (fillPortion 4), alignTop ]
            (List.map (\r -> viewRelationship r language) relation.items)
        ]


viewRelationship : Relationship -> Language -> Element Msg
viewRelationship relationship language =
    let
        role =
            case relationship.role of
                Just relationshipRole ->
                    "[" ++ extractLabelFromLanguageMap language relationshipRole ++ "]"

                Nothing ->
                    ""

        relatedTo =
            case relationship.relatedTo of
                Just rel ->
                    viewLinkedRelatedTo rel role language

                Nothing ->
                    case relationship.value of
                        Just rel ->
                            viewUnlinkedRelatedTo rel role language

                        Nothing ->
                            none
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ relatedTo ]
        ]


viewLinkedRelatedTo : RelatedEntity -> String -> Language -> Element Msg
viewLinkedRelatedTo entity role language =
    let
        relationshipLink =
            styledLink entity.id (extractLabelFromLanguageMap language entity.name)

        relationshipAttributes =
            if String.length role > 0 then
                [ width fill
                , bodyRegular
                , paddingEach { top = 0, left = 10, bottom = 0, right = 0 }
                ]

            else
                [ width fill
                , bodyRegular
                ]
    in
    paragraph
        [ width fill
        ]
        [ relationshipLink
        , el
            relationshipAttributes
            (text role)
        ]


viewUnlinkedRelatedTo : LanguageMap -> String -> Language -> Element Msg
viewUnlinkedRelatedTo relatedEntity role language =
    let
        relationshipName =
            extractLabelFromLanguageMap language relatedEntity

        relationshipAttributes =
            if String.length role > 0 then
                [ width fill
                , bodyRegular
                , paddingEach { top = 0, left = 10, bottom = 0, right = 0 }
                ]

            else
                [ width fill
                , bodyRegular
                ]
    in
    paragraph
        [ width fill ]
        [ el
            [ bodyRegular ]
            (text relationshipName)
        , el
            relationshipAttributes
            (text role)
        ]


viewReferencesNotesSection : PersonBody -> Language -> Element Msg
viewReferencesNotesSection body language =
    case body.notes of
        Just noteList ->
            viewReferencesNotes noteList language

        Nothing ->
            none


viewReferencesNotes : NoteList -> Language -> Element Msg
viewReferencesNotes noteList language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill
            , spacingXY 0 10
            ]
            [ row
                [ width fill
                ]
                [ h4 language noteList.label ]
            , row
                [ width fill
                ]
                [ column
                    [ width fill ]
                    [ viewSummaryField noteList.notes language ]
                ]
            ]
        ]


viewExternalResourcesSectionSection : PersonBody -> Language -> Element Msg
viewExternalResourcesSectionSection body language =
    case body.externalResources of
        Just resources ->
            viewExternalResources resources language

        Nothing ->
            none


viewExternalResources : ExternalResourceList -> Language -> Element Msg
viewExternalResources resourceList language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , paddingXY 0 10
                ]
                [ h4 language resourceList.label ]
            , row
                [ width fill ]
                [ column
                    [ spacingXY 0 10 ]
                    (List.map (\n -> viewExternalResource n language) resourceList.items)
                ]
            ]
        ]


viewExternalResource : ExternalResource -> Language -> Element Msg
viewExternalResource externalResource language =
    styledLink externalResource.url (extractLabelFromLanguageMap language externalResource.label)
