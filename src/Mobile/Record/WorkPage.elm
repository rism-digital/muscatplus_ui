module Mobile.Record.WorkPage exposing (viewFullMobileWorkPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, paddingEach, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewSourceSearchTabBody)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Work exposing (WorkBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Images exposing (userMusicSvg)
import Page.UI.Record.Bodies.Work exposing (viewWorkSections)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Record.TabShell exposing (selectBody, sourceSearchTabs, viewMobileTabBar)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobileWorkPage :
    Session
    -> RecordPageModel RecordMsg
    -> WorkBody
    -> Element RecordMsg
viewFullMobileWorkPage session model body =
    let
        descriptionBody =
            viewDescriptionTab session model body

        tabs =
            sourceSearchTabs
                { bodyView = viewSourceSearchTabBody session model
                , currentTab = model.currentTab
                , descriptionBodyView = descriptionBody
                , descriptionShowBottomShadow = True
                , fallbackBody = body.sources
                , language = session.language
                , recordId = body.id
                , searchResults = model.searchResults
                , searchShowBottomShadow = False
                , tabLabel = localTranslations.sources
                }

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                ]
                (userMusicSvg colourScheme.darkBlue)
    in
    viewMobileRecordPage
        { session = session
        , body = body
        , icon = icon
        , topBar = viewMobileTabBar tabs
        , bodyView = (selectBody { bodyView = descriptionBody, showBottomShadow = True } tabs).bodyView
        }


viewDescriptionTab : Session -> RecordPageModel RecordMsg -> WorkBody -> Element RecordMsg
viewDescriptionTab session model body =
    row
        [ width fill
        , height fill
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , paddingEach { bottom = 90, left = 20, right = 20, top = 20 }
            , spacing sectionSpacing
            ]
            (viewWorkSections
                { expandedIncipits = model.incipitInfoExpanded
                , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                , language = session.language
                , paragraphFormatter = viewMobileParagraphField
                , preRenderedFormatter = viewPreRenderedMobileSummaryField
                , recordId = body.id
                , relationshipFormatter = viewMobileRelationshipBody
                , summaryFormatter = viewMobileSummaryField
                }
                body
            )
        ]
