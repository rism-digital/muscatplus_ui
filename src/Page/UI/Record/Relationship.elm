module Page.UI.Record.Relationship exposing (..)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, link, none, px, row, shrink, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelatedTo(..), RelatedToBody, RelationshipBody, RelationshipsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel)
import Page.UI.Images exposing (institutionSvg, mapMarkerSvg, peopleSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionBody =
            [ row
                ([ width fill
                 , height fill
                 , alignTop
                 ]
                    ++ sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
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
    let
        relIcon =
            case body.type_ of
                PersonRelationship ->
                    peopleSvg colourScheme.slateGrey

                InstitutionRelationship ->
                    institutionSvg colourScheme.slateGrey

                PlaceRelationship ->
                    mapMarkerSvg colourScheme.slateGrey

                UnknownRelationship ->
                    none
    in
    el
        [ width shrink ]
        (row
            [ width fill
            , spacing 5
            ]
            [ el
                [ width <| px 16
                , height <| px 16
                , centerY
                ]
                relIcon
            , link
                [ linkColour ]
                { url = body.id
                , label = text (extractLabelFromLanguageMap language body.label)
                }
            ]
        )
