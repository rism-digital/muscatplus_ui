module Page.Record.Views.SourcePage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, column, fill, height, maximum, minimum, row, spacing, width)
import Language exposing (Language)
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
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing, widthFillHeightFill)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Incipits exposing (viewIncipitsSection)


viewFullSourcePage : Language -> FullSourceBody -> Element RecordMsg
viewFullSourcePage language body =
    let
        pageBodyView =
            row
                widthFillHeightFill
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    , alignTop
                    ]
                    [ viewMaybe (viewPartOfSection language) body.partOf
                    , viewMaybe (viewContentsSection language) body.contents
                    , viewMaybe (viewIncipitsSection language) body.incipits
                    , viewMaybe (viewMaterialGroupsSection language) body.materialGroups
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewReferencesNotesSection language) body.referencesNotes
                    , viewMaybe (viewSourceItemsSection language) body.items
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    , viewMaybe (viewExemplarsSection language) body.exemplars
                    ]
                ]
    in
    row
        [ width (fill |> minimum 800 |> maximum 1400)
        , height fill
        ]
        [ column
            (List.append [ spacing sectionSpacing ] widthFillHeightFill)
            [ row
                [ width fill
                , alignTop
                ]
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ pageHeaderTemplate language body
                    , pageUriTemplate language body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate language body
            ]
        ]
