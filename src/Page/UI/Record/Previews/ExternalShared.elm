module Page.UI.Record.Previews.ExternalShared exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, fill, height, row, textColumn, width, wrappedRow)
import Language exposing (Language)
import Page.RecordTypes.ExternalRecord exposing (ExternalRelationshipBody, ExternalRelationshipsSection)
import Page.RecordTypes.Relationship exposing (RelatedTo(..))
import Page.UI.Attributes exposing (bodyRegular, labelFieldColumnAttributes, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelatedToBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewExternalRelationshipsSection : Language -> ExternalRelationshipsSection -> Element msg
viewExternalRelationshipsSection language body =
    List.map (viewExternalRelationshipBody language) body.items
        |> sectionTemplate language body


viewExternalRelationshipBody : Language -> ExternalRelationshipBody -> Element msg
viewExternalRelationshipBody language body =
    let
        roleLabel =
            viewMaybe (\role -> renderLabel language role.label) body.role

        relatedToView =
            viewMaybe (viewRelatedToBody language) body.relatedTo
    in
    fieldValueWrapper []
        [ wrappedRow
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
                        ]
                    ]
                ]
            ]
        ]
