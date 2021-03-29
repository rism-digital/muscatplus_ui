module Records.Views.Source exposing (..)

import Api.Records exposing (Exemplar, ExemplarsList, Incipit, IncipitFormat(..), IncipitList, MaterialGroup, MaterialGroupList, NoteList, RenderedIncipit(..), SourceBody, SourceRelationship, SourceRelationshipList)
import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, link, none, paddingEach, paddingXY, paragraph, px, row, spacing, text, width)
import Element.Border as Border
import Language exposing (Language, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Msg)
import Records.Views.Shared exposing (viewSummaryField)
import SvgParser
import UI.Components exposing (h2, h4, h5, label, styledLink, value)
import UI.Style exposing (bodyRegular, borderBottom, lightBlue, red)


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
            [ viewSummaryField body.summary language ]
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
        relatedPeople =
            case materialgroup.related of
                Just related ->
                    viewRelatedPeople related language

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
                []
                [ h5 language materialgroup.label ]
            , viewSummaryField materialgroup.summary language
            , relatedPeople
            ]
        ]


viewRelatedPeople : SourceRelationshipList -> Language -> Element Msg
viewRelatedPeople related language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , paddingXY 0 10
                ]
                [ h5 language related.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\p -> viewRelatedPerson p language) related.items)
                ]
            ]
        ]


viewRelatedPerson : SourceRelationship -> Language -> Element Msg
viewRelatedPerson relationship language =
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

        person =
            relationship.person

        relatedPerson =
            styledLink person.id (extractLabelFromLanguageMap language person.label)
    in
    row
        [ width fill
        , paddingXY 10 5
        ]
        [ paragraph
            [ bodyRegular ]
            [ relatedPerson
            , text (" " ++ relationshipRole)
            , text (" " ++ relationshipQualifier)
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


viewExemplarsSection : SourceBody -> Language -> Element Msg
viewExemplarsSection body language =
    case body.exemplars of
        Just hold ->
            viewExemplars hold language

        Nothing ->
            none


viewExemplars : ExemplarsList -> Language -> Element Msg
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

        institutionSiglum =
            "(" ++ extractLabelFromLanguageMap language heldByInstitution.siglum ++ ")"

        heldByLink =
            styledLink heldByInstitution.id (extractLabelFromLanguageMap language heldByInstitution.label)
    in
    row
        [ width fill
        , paddingXY 10 5
        ]
        [ column
            [ width fill ]
            [ paragraph
                [ bodyRegular ]
                [ heldByLink
                , text (" " ++ institutionSiglum)
                ]
            ]
        ]
