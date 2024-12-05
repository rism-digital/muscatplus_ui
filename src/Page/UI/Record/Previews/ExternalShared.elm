module Page.UI.Record.Previews.ExternalShared exposing (viewExternalRelationshipsSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.ExternalRecord exposing (ExternalRelationshipBody, ExternalRelationshipsSection)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Record.Relationship exposing (gatherRelationshipItems)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewExternalRelationshipsSection :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> ExternalRelationshipsSection
    -> Element msg
viewExternalRelationshipsSection { language, relationshipFormatter } body =
    sectionTemplate language
        body
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
                (List.map
                    (viewExternalRelationshipBody
                        { language = language
                        , relationshipFormatter = relationshipFormatter
                        }
                    )
                    body.items
                )
            ]
        ]


viewExternalRelationshipBody :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> ExternalRelationshipBody
    -> Element msg
viewExternalRelationshipBody { language, relationshipFormatter } body =
    let
        relationshipBody =
            [ { role = body.role
              , qualifier = body.qualifier
              , relatedTo = body.relatedTo
              , name = Nothing
              , note = body.note
              }
            ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            (gatherRelationshipItems relationshipBody
                |> List.map (\( label, items ) -> relationshipFormatter language label items)
            )
        ]
