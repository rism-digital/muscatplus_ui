module Page.Search.Views.Previews.Source exposing (..)

import Element exposing (Element, column, el, fill, height, link, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Page.Record.Views.SourcePage.ContentsSection exposing (viewContentsSection)
import Page.Record.Views.SourcePage.ExemplarsSection exposing (viewExemplarsSection)
import Page.Record.Views.SourcePage.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.Record.Views.SourcePage.PartOfSection exposing (viewPartOfSection)
import Page.Record.Views.SourcePage.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.Record.Views.SourcePage.SourceItemsSection exposing (viewSourceItemsSection)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h4)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Incipits exposing (viewIncipitsSection)
import Page.Views.Relationship exposing (viewRelationshipsSection)


viewSourcePreview : Language -> FullSourceBody -> Element msg
viewSourcePreview language body =
    let
        fullSourceLink =
            row
                [ width fill
                ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ linkColour ]
                    { url = body.id, label = text body.id }
                ]
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 5
            ]
            [ row
                [ width fill ]
                [ h4 language body.label ]
            , fullSourceLink
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewMaybe (viewPartOfSection language) body.partOf
                    , viewMaybe (viewContentsSection language) body.contents
                    , viewMaybe (viewExemplarsSection language) body.exemplars
                    , viewMaybe (viewIncipitsSection language) body.incipits
                    , viewMaybe (viewMaterialGroupsSection language) body.materialGroups
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewReferencesNotesSection language) body.referencesNotes
                    , viewMaybe (viewSourceItemsSection language) body.items
                    ]
                ]
            ]
        ]
