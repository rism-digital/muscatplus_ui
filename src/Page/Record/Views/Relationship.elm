module Page.Record.Views.Relationship exposing (..)

import Element exposing (Element, alignTop, column, el, fill, height, link, none, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes, widthFillHeightFill)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionBody =
            [ row
                (List.concat [ widthFillHeightFill, sectionBorderStyles ])
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    (List.map (\t -> viewRelationshipBody language t) relSection.items)
                ]
            ]
    in
    sectionTemplate language relSection sectionBody


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
    fieldValueWrapper <|
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language body.label ]
            , column
                valueFieldColumnAttributes
                [ row
                    [ width fill ]
                    [ relatedToView
                    , qualifierLabel
                    ]
                ]
            ]
        ]


viewRelatedToBody : Language -> RelatedToBody -> Element msg
viewRelatedToBody language body =
    link
        [ linkColour ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }
