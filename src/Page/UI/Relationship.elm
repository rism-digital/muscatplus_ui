module Page.UI.Relationship exposing (..)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, htmlAttribute, link, none, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (h5, label)
import Page.UI.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


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
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                ]
                [ el
                    [ width (fillPortion 1)
                    , alignTop
                    ]
                    (label language body.label)
                , row
                    [ width (fillPortion 6)
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
        [ linkColour ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }
