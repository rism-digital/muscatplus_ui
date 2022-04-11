module Page.Record.Views.SourcePage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, padding, paddingXY, px, row, scrollbarY, spacing, spacingXY, width)
import Element.Background as Background
import Element.Border as Border
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.SourcePage.RelationshipsSection exposing (viewRelationshipsSection)
import Page.Record.Views.SourceSearch exposing (viewRecordTopBarDescriptionOnly)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (sourceSvg, sourcesSvg)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)
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
                , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
                , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
                , Background.color (colourScheme.cream |> convertColorToElementColor)
                ]
                [ column
                    [ width (px 80) ]
                    [ el
                        [ width (px 48)
                        , height (px 48)
                        , centerX
                        , centerY
                        ]
                        (sourcesSvg colourScheme.slateGrey)
                    ]
                , column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacingXY 0 lineSpacing
                    , paddingXY 5 20
                    ]
                    [ pageHeaderTemplate session.language body
                    , viewRecordTopBarDescriptionOnly
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]
