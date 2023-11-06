module Page.UI.Record.Previews.ExternalShared exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalRecord exposing (ExternalRelationshipBody, ExternalRelationshipsSection)
import Page.RecordTypes.Relationship exposing (RelatedTo(..))
import Page.UI.Attributes exposing (bodyRegular, labelFieldColumnAttributes, lineSpacing, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelatedToBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewExternalRelationshipsSection : Language -> ExternalRelationshipsSection -> Element msg
viewExternalRelationshipsSection language body =
    let
        sectionTmpl =
            sectionTemplate language body
    in
    sectionTmpl
        [ row
            (width fill
                :: height fill
                :: alignTop
                :: sectionBorderStyles
            )
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                (List.map (viewExternalRelationshipBody language) body.items)
            ]
        ]


viewExternalRelationshipBody : Language -> ExternalRelationshipBody -> Element msg
viewExternalRelationshipBody language body =
    let
        roleLabel =
            viewMaybe (\role -> renderLabel language role.label) body.role

        qualifierLabel =
            viewMaybe
                (\qual ->
                    el [] (text (" [" ++ extractLabelFromLanguageMap language qual.label ++ "]"))
                )
                body.qualifier

        relatedToView =
            viewMaybe (viewRelatedToBody language) body.relatedTo
    in
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            labelFieldColumnAttributes
            [ roleLabel ]
        , column
            valueFieldColumnAttributes
            [ textColumn
                [ bodyRegular ]
                [ row
                    [ alignLeft
                    ]
                    [ relatedToView
                    , qualifierLabel
                    ]
                ]
            ]
        ]
