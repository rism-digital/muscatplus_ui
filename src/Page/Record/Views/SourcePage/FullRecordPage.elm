module Page.Record.Views.SourcePage.FullRecordPage exposing (viewFullSourcePage)

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerX, centerY, column, el, fill, height, padding, paddingXY, px, row, scrollbarY, spacing, spacingXY, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.Record.Views.SourcePage.RelationshipsSection exposing (viewRelationshipsSection)
import Page.Record.Views.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTab)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Session exposing (Session)
import Set exposing (Set)


viewDescriptionTab : Language -> (String -> msg) -> Set String -> FullSourceBody -> Element msg
viewDescriptionTab language incipitInfoToggleMsg expandedIncipits body =
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
            , viewMaybe (viewIncipitsSection { language = language, infoToggleMsg = incipitInfoToggleMsg, expandedIncipits = expandedIncipits }) body.incipits
            , viewMaybe (viewMaterialGroupsSection language) body.materialGroups
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewReferencesNotesSection language) body.referencesNotes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            , viewMaybe (viewExemplarsSection language) body.exemplars
            , viewMaybe (viewDigitalObjectsSection language) body.digitalObjects
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
                    viewDescriptionTab
                        session.language
                        RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        model.incipitInfoExpanded
                        body

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
                , height (px searchHeaderHeight)
                , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
                , Border.color (colourScheme.darkBlue |> convertColorToElementColor)

                --, Background.color (colourScheme.cream |> convertColorToElementColor)
                ]
                [ column
                    [ width fill
                    , height fill
                    , paddingXY 20 0
                    , centerY
                    , alignLeft
                    , spacingXY 0 lineSpacing

                    --, alignBottom
                    --, paddingXY 5 20
                    ]
                    [ pageHeaderTemplate session.language Nothing body
                    , viewRecordTopBarRouter session.language model body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]


viewRecordTopBarRouter : Language -> RecordPageModel RecordMsg -> FullSourceBody -> Element RecordMsg
viewRecordTopBarRouter language model body =
    viewMaybe
        (\sourceBlock ->
            viewIf
                (viewRecordSourceSearchTabBar
                    { language = language
                    , model = model
                    , recordId = body.id
                    , searchUrl = sourceBlock.url
                    , tabLabel = localTranslations.sourceContents
                    }
                )
                (sourceBlock.totalItems /= 0)
        )
        body.sourceItems
