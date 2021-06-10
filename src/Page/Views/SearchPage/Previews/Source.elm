module Page.Views.SearchPage.Previews.Source exposing (..)

import Element exposing (Element, column, el, fill, height, link, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Components exposing (h4)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Incipits exposing (viewIncipitsSection)
import Page.Views.SourcePage.ContentsSection exposing (viewContentsSection)
import Page.Views.SourcePage.ExemplarsSection exposing (viewExemplarsSection)
import Page.Views.SourcePage.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.Views.SourcePage.PartOfSection exposing (viewPartOfSection)
import Page.Views.SourcePage.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.Views.SourcePage.RelationshipsSection exposing (viewRelationshipsSection)
import Page.Views.SourcePage.SourceItemsSection exposing (viewSourceItemsSection)


viewSourcePreview : FullSourceBody -> Language -> Element Msg
viewSourcePreview body language =
    let
        fullSourceLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
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
