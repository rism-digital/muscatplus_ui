module Records.Views.Shared exposing (..)

import Element exposing (DeviceClass(..), Element, alignTop, centerX, centerY, column, el, fill, fillPortion, height, none, paddingEach, paddingXY, paragraph, row, text, width)
import Records.DataTypes exposing (Model, Msg, RelatedEntity, RelatedList, Relationship, Relationships)
import Shared.DataTypes exposing (LabelValue)
import Shared.Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import UI.Components exposing (h4, label, styledLink, value)
import UI.Style exposing (bodyRegular)


viewLoadingSpinner : Model -> Element Msg
viewLoadingSpinner model =
    row
        [ width fill ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ el
                    [ centerX
                    , centerY
                    ]
                    (text "Loading")
                ]
            ]
        ]


viewErrorMessage : Model -> Element Msg
viewErrorMessage model =
    el [ centerX, centerY ] (text model.errorMessage)


viewSummaryField : List LabelValue -> Language -> Element msg
viewSummaryField field language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            (List.map
                (\f ->
                    row
                        [ width fill, paddingXY 0 10 ]
                        [ el
                            [ width (fillPortion 2), alignTop ]
                            (label language f.label)
                        , el
                            [ width (fillPortion 4), alignTop ]
                            (value language f.value)
                        ]
                )
                field
            )
        ]


viewRelations : RelatedList -> Language -> Element Msg
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


viewRelationTypes : Relationships -> Language -> Element Msg
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
            styledLink entity.id (extractLabelFromLanguageMap language entity.label)

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
