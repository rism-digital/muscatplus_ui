module Desktop.Record.WorkPage exposing (viewFullWorkPage)

import Desktop.Record.PageShell exposing (TabBody, viewDesktopRecordPage)
import Desktop.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Work exposing (WorkBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Images exposing (userMusicSvg)
import Page.UI.Record.Bodies.Work exposing (viewWorkSections)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)
import Set exposing (Set)


viewFullWorkPage :
    Session
    -> RecordPageModel RecordMsg
    -> WorkBody
    -> Element RecordMsg
viewFullWorkPage session model body =
    let
        language =
            session.language

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (userMusicSvg colourScheme.darkBlue)
    in
    viewDesktopRecordPage
        { session = session
        , body = body
        , icon = icon
        , chooseBody = chooseBody session model body
        , currentTab = model.currentTab
        , tabBar =
            viewRecordSourceSearchTabBar
                { body = body.sources
                , language = language
                , model = model
                , recordId = body.id
                , tabLabel = localTranslations.sources
                }
        }


chooseBody : Session -> RecordPageModel RecordMsg -> WorkBody -> CurrentRecordViewTab -> TabBody RecordMsg
chooseBody session model body currentTab =
    case currentTab of
        DefaultRecordViewTab _ ->
            { bodyView =
                viewDescriptionTab
                    { expandedIncipits = model.incipitInfoExpanded
                    , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                    , language = session.language
                    }
                    body
            , showBottomShadow = True
            }

        ContentsSearchDisplayTab _ ->
            { bodyView = viewSourceSearchTabBody session model
            , showBottomShadow = False
            }

        _ ->
            { bodyView =
                viewDescriptionTab
                    { expandedIncipits = model.incipitInfoExpanded
                    , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                    , language = session.language
                    }
                    body
            , showBottomShadow = True
            }

viewDescriptionTab :
    { expandedIncipits : Set String
    , incipitInfoToggleMsg : String -> RecordMsg
    , language : Language
    }
    -> WorkBody
    -> Element RecordMsg
viewDescriptionTab { expandedIncipits, incipitInfoToggleMsg, language } body =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , spacing sectionSpacing
            , alignTop
            , padding 20
            ]
            (viewWorkSections
                { expandedIncipits = expandedIncipits
                , incipitInfoToggleMsg = incipitInfoToggleMsg
                , language = language
                , paragraphFormatter = viewParagraphField
                , preRenderedFormatter = viewPreRenderedSummaryField
                , recordId = body.id
                , relationshipFormatter = viewRelationshipBody
                , summaryFormatter = viewSummaryField
                }
                body
            )
        ]
