module Page.Views.Relationship exposing (..)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, link, none, paddingXY, row, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody)
import Page.UI.Components exposing (label)
import Page.UI.Style exposing (colourScheme)


viewRelationshipBody : RelationshipBody -> Language -> Element msg
viewRelationshipBody body language =
    let
        relatedToView =
            -- if there is a related-to relationship, display that.
            -- if all we have is a name, display that.
            -- if neither, don't show anything because we can't!
            case body.relatedTo of
                Just rel ->
                    viewRelatedToBody rel language

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


viewRelatedToBody : RelatedToBody -> Language -> Element msg
viewRelatedToBody body language =
    link
        [ Font.color colourScheme.lightBlue ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }
