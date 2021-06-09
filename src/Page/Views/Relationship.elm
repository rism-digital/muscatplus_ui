module Page.Views.Relationship exposing (..)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, htmlAttribute, link, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Components exposing (h5, label)
import Page.UI.Style exposing (colourScheme)


viewPersonRelationshipsSection : Language -> RelationshipsSectionBody -> Element Msg
viewPersonRelationshipsSection language relSection =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill
                , htmlAttribute (HTA.id relSection.sectionToc)
                ]
                [ h5 language relSection.label ]
            , row
                [ width fill
                ]
                [ column
                    [ width fill
                    ]
                    (List.map (\t -> viewRelationshipBody language t) relSection.items)
                ]
            ]
        ]


viewRelationshipBody : Language -> RelationshipBody -> Element msg
viewRelationshipBody language body =
    let
        relatedToView =
            -- if there is a related-to relationship, display that.
            -- if all we have is a name, display that.
            -- if neither, don't show anything because we can't!
            case body.relatedTo of
                Just rel ->
                    viewRelatedToBody language rel

                Nothing ->
                    case body.name of
                        Just nm ->
                            el [] (text (extractLabelFromLanguageMap language nm))

                        Nothing ->
                            none

        qualifierLabel =
            case body.qualifierLabel of
                Just qual ->
                    el [] (text (" [" ++ extractLabelFromLanguageMap language qual ++ "]"))

                Nothing ->
                    none
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , paddingXY 0 10
                ]
                [ el
                    [ width (fillPortion 1)
                    , alignTop
                    ]
                    (label language body.label)
                , row
                    [ width (fillPortion 4)
                    , alignTop
                    ]
                    [ relatedToView
                    , qualifierLabel
                    ]
                ]
            ]
        ]


viewRelatedToBody : Language -> RelatedToBody -> Element msg
viewRelatedToBody language body =
    link
        [ Font.color colourScheme.lightBlue ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }
