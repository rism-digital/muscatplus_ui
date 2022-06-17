module Page.Record.Views.SourcePage.FullRecordPage exposing (viewDescriptionTab, viewFullSourcePage, viewRecordTopBarRouter)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, none, padding, paddingXY, px, row, scrollbarY, spacing, spacingXY, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.SourcePage.RelationshipsSection exposing (viewRelationshipsSection)
import Page.Record.Views.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTab)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)


viewDescriptionTab : Language -> FullSourceBody -> Element msg
viewDescriptionTab language body =
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
            [ viewMaybe (viewPartOfSection language) body.partOf
            , viewMaybe (viewContentsSection language body.creator) body.contents
            , viewMaybe (viewIncipitsSection language) body.incipits
            , viewMaybe (viewMaterialGroupsSection language) body.materialGroups
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewReferencesNotesSection language) body.referencesNotes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            , viewMaybe (viewExemplarsSection language) body.exemplars
            ]
        ]


viewFullSourcePage :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewFullSourcePage session model body =
    let
        pageBodyView =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    viewDescriptionTab session.language body

                RelatedSourcesSearchTab _ ->
                    viewSourceSearchTab session model
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
                , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
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
                    , viewRecordTopBarRouter session.language model body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]


viewRecordTopBarRouter : Language -> RecordPageModel RecordMsg -> FullSourceBody -> Element RecordMsg
viewRecordTopBarRouter language model body =
    case body.sourceItems of
        Just sourceBlock ->
            if sourceBlock.totalItems == 0 then
                none

            else
                viewRecordSourceSearchTabBar
                    { language = language
                    , model = model
                    , recordId = body.id
                    , searchUrl = sourceBlock.url
                    , tabLabel = localTranslations.sourceContents
                    }

        Nothing ->
            none
