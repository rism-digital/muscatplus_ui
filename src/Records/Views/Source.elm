module Records.Views.Source exposing (..)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, none, paddingXY, paragraph, px, row, spacing, text, width)
import Records.DataTypes exposing (Exemplar, ExemplarList, Incipit, IncipitFormat(..), IncipitList, MaterialGroup, MaterialGroupList, Msg, NoteList, Relations, Relationship, RelationshipList, RenderedIncipit(..), SourceBody)
import Records.Views.Shared exposing (viewSummaryField)
import Shared.Language exposing (Language, extractLabelFromLanguageMap)
import SvgParser
import UI.Components exposing (h2, h4, h5, label, styledLink, value)
import UI.Style exposing (bodyRegular)


viewSourceRecord : SourceBody -> Language -> Element Msg
viewSourceRecord body language =
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
                , height (fillPortion 10)
                ]
                [ column
                    [ width fill
                    , spacing 20
                    ]
                    (List.map (\viewSection -> viewSection body language)
                        [ viewSummarySection
                        , viewNotesSection
                        , viewIncipitSection
                        , viewDistributionSection
                        , viewRelationsSection
                        , viewMaterialDescriptionSection
                        , viewFurtherInformationSection
                        , viewReferencesSection
                        , viewIndexTermsSection
                        , viewExemplarsSection
                        ]
                    )
                ]
            ]
        ]


viewSummarySection : SourceBody -> Language -> Element Msg
viewSummarySection body language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ viewCreatorSection body language
            , viewSummaryField body.summary language
            ]
        ]


viewCreatorSection : SourceBody -> Language -> Element Msg
viewCreatorSection body language =
    case body.creator of
        Just creator ->
            viewCreator creator language

        Nothing ->
            none


viewCreator : Relationship -> Language -> Element Msg
viewCreator creator language =
    let
        creatorLabel =
            case creator.role of
                Just role ->
                    label language role

                -- for creators hopefully it will always have a role, but we add a Nothing case to satisfy the maybe
                -- for other types of relationships
                Nothing ->
                    text "[No label]"

        creatorValue =
            case creator.relatedTo of
                Just r ->
                    styledLink r.id (extractLabelFromLanguageMap language r.label)

                Nothing ->
                    none
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill, paddingXY 0 10 ]
                [ el
                    [ width (fillPortion 2), alignTop ]
                    creatorLabel
                , el
                    [ width (fillPortion 4), alignTop ]
                    creatorValue
                ]
            ]
        ]


viewNotesSection : SourceBody -> Language -> Element Msg
viewNotesSection body language =
    case body.notes of
        Just notelist ->
            viewNotes notelist language

        Nothing ->
            Element.none


viewNotes : NoteList -> Language -> Element Msg
viewNotes notelist language =
    row
        [ width fill, paddingXY 0 10 ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ h4 language notelist.label
                ]
            , viewSummaryField notelist.notes language
            ]
        ]


viewIncipitSection : SourceBody -> Language -> Element Msg
viewIncipitSection body language =
    case body.incipits of
        Just incipitList ->
            viewIncipits incipitList language

        Nothing ->
            Element.none


viewIncipits : IncipitList -> Language -> Element Msg
viewIncipits incipitlist language =
    row
        [ width fill ]
        [ column
            [ width fill
            ]
            [ row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ h4 language incipitlist.label ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (viewSingleIncipit language) incipitlist.incipits)
                ]
            ]
        ]


viewSingleIncipit : Language -> Incipit -> Element Msg
viewSingleIncipit language incipit =
    let
        renderedIncipits =
            case incipit.rendered of
                Just renderedIncipitList ->
                    viewRenderedIncipits renderedIncipitList

                Nothing ->
                    Element.none
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill ]
            [ viewSummaryField incipit.summary language
            , renderedIncipits
            ]
        ]


viewRenderedIncipits : List RenderedIncipit -> Element Msg
viewRenderedIncipits incipitList =
    let
        incipitSVG =
            List.map
                (\rendered ->
                    case rendered of
                        RenderedIncipit RenderedSVG svgdata ->
                            viewSVGRenderedIncipit svgdata

                        _ ->
                            Element.none
                )
                incipitList
    in
    row
        [ paddingXY 0 10
        , width fill
        , height fill
        ]
        incipitSVG


{-|

    Parses an Elm SVG tree (returns Html) from the JSON incipit data.
    Converts it to an elm-ui structure to match the other view functions

-}
viewSVGRenderedIncipit : String -> Element Msg
viewSVGRenderedIncipit incipitData =
    let
        svgData =
            SvgParser.parse incipitData

        svgResponse =
            case svgData of
                Ok html ->
                    Element.html html

                Err error ->
                    text "Could not parse SVG"
    in
    svgResponse


viewDistributionSection : SourceBody -> Language -> Element Msg
viewDistributionSection body language =
    none


{-|

    Displays the relationships defined on the source directly. If
    a relationship is defined on a material group, that is handled
    in the Material Group section (below).

-}
viewRelationsSection : SourceBody -> Language -> Element Msg
viewRelationsSection body language =
    case body.related of
        Just relations ->
            viewRelations relations language

        Nothing ->
            none


viewRelations : Relations -> Language -> Element Msg
viewRelations relations language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ h4 language relations.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\rl -> viewRelationshipList rl language) relations.items)
                ]
            ]
        ]


viewRelationshipList : RelationshipList -> Language -> Element Msg
viewRelationshipList relationships language =
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
                    (List.map (\re -> viewRelationship re language) relationships.items)
                ]
            ]
        ]


viewRelationship : Relationship -> Language -> Element Msg
viewRelationship relationship language =
    let
        relationshipRole =
            case relationship.role of
                Just role ->
                    "[" ++ extractLabelFromLanguageMap language role ++ "]"

                Nothing ->
                    ""

        relationshipQualifier =
            case relationship.qualifier of
                Just qual ->
                    "[" ++ extractLabelFromLanguageMap language qual ++ "]"

                Nothing ->
                    ""

        relatedEntity =
            case relationship.relatedTo of
                Just r ->
                    styledLink r.id (extractLabelFromLanguageMap language r.label)

                Nothing ->
                    none
    in
    row
        [ width fill
        , paddingXY 10 5
        ]
        [ paragraph
            [ bodyRegular ]
            [ relatedEntity
            , text (" " ++ relationshipRole)
            , text (" " ++ relationshipQualifier)
            ]
        ]


viewMaterialDescriptionSection : SourceBody -> Language -> Element Msg
viewMaterialDescriptionSection body language =
    case body.materialgroups of
        Just materialgroups ->
            viewMaterialDescriptions materialgroups language

        Nothing ->
            none


viewMaterialDescriptions : MaterialGroupList -> Language -> Element Msg
viewMaterialDescriptions materialgroups language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill
            ]
            [ row
                [ width fill ]
                [ h4 language materialgroups.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\gp -> viewMaterialGroup gp language) materialgroups.items)
                ]
            ]
        ]


viewMaterialGroup : MaterialGroup -> Language -> Element Msg
viewMaterialGroup materialgroup language =
    let
        relations =
            case materialgroup.related of
                Just related ->
                    viewRelations related language

                Nothing ->
                    none
    in
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ h5 language materialgroup.label ]
            , viewSummaryField materialgroup.summary language
            , relations
            ]
        ]


viewFurtherInformationSection : SourceBody -> Language -> Element Msg
viewFurtherInformationSection body language =
    none


viewReferencesSection : SourceBody -> Language -> Element Msg
viewReferencesSection body language =
    none


viewIndexTermsSection : SourceBody -> Language -> Element Msg
viewIndexTermsSection body language =
    none


{-|

    Exemplars <-> Holdings. They're the same thing.

-}
viewExemplarsSection : SourceBody -> Language -> Element Msg
viewExemplarsSection body language =
    case body.exemplars of
        Just hold ->
            viewExemplars hold language

        Nothing ->
            none


viewExemplars : ExemplarList -> Language -> Element Msg
viewExemplars exemplarlist language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ h4 language exemplarlist.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\e -> viewSingleExemplar e language) exemplarlist.items)
                ]
            ]
        ]


viewSingleExemplar : Exemplar -> Language -> Element Msg
viewSingleExemplar exemplar language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ viewHeldByInstitution exemplar language
            , viewSummaryField exemplar.summary language
            ]
        ]


viewHeldByInstitution : Exemplar -> Language -> Element Msg
viewHeldByInstitution exemplar language =
    let
        heldByInstitution =
            exemplar.heldBy

        --institutionSiglum =
        --    "(" ++ extractLabelFromLanguageMap language heldByInstitution.siglum ++ ")"
        heldByLink =
            styledLink heldByInstitution.id (extractLabelFromLanguageMap language heldByInstitution.label)
    in
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ paragraph
                [ bodyRegular ]
                [ heldByLink
                ]
            ]
        ]
