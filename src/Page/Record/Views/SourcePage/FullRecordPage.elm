module Page.Record.Views.SourcePage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Record.Views.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate, pageUriTemplate)
import Page.Record.Views.SourcePage.ContentsSection exposing (viewContentsSection)
import Page.Record.Views.SourcePage.ExemplarsSection exposing (viewExemplarsSection)
import Page.Record.Views.SourcePage.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.Record.Views.SourcePage.PartOfSection exposing (viewPartOfSection)
import Page.Record.Views.SourcePage.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.Record.Views.SourcePage.RelationshipsSection exposing (viewRelationshipsSection)
import Page.Record.Views.SourcePage.SourceItemsSection exposing (viewSourceItemsSection)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Incipits exposing (viewIncipitsSection)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)


viewFullSourcePage : Session -> FullSourceBody -> Element RecordMsg
viewFullSourcePage session body =
    let
        pageBodyView =
            row
                [ width fill
                , height fill
                , alignTop
                , scrollbarY
                ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    , alignTop
                    , padding 20
                    ]
                    [ viewMaybe (viewPartOfSection session.language) body.partOf
                    , viewMaybe (viewContentsSection session.language) body.contents
                    , viewMaybe (viewIncipitsSection session.language) body.incipits
                    , viewMaybe (viewMaterialGroupsSection session.language) body.materialGroups
                    , viewMaybe (viewRelationshipsSection session.language) body.relationships
                    , viewMaybe (viewReferencesNotesSection session.language) body.referencesNotes
                    , viewMaybe (viewSourceItemsSection session.language) body.items
                    , viewMaybe (viewExternalResourcesSection session.language) body.externalResources
                    , viewMaybe (viewExemplarsSection session.language) body.exemplars
                    ]
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
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    , padding 20
                    , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
                    , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
                    , Background.color (colourScheme.cream |> convertColorToElementColor)
                    ]
                    [ pageHeaderTemplate session.language body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]
