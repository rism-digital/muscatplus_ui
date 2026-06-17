module Mobile.Record.PersonPage exposing (viewFullMobilePersonPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewSourceSearchTabBody)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewMobileParagraphField, viewMobileSummaryField)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.Bodies.Person exposing (viewPersonSections)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Record.TabShell exposing (selectBody, sourceSearchTabs, viewMobileTabBar)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobilePersonPage :
    Session
    -> RecordPageModel RecordMsg
    -> PersonBody
    -> Element RecordMsg
viewFullMobilePersonPage session model body =
    let
        descriptionBody =
            viewDescriptionTab session body

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
                (peopleSvg colourScheme.darkBlue)
    in
    viewMobileRecordPage
        { session = session
        , body = body
        , icon = icon
        , topBar = viewMobileTabBar tabs
        , bodyView = (selectBody { bodyView = descriptionBody, showBottomShadow = True } tabs).bodyView
        }


viewDescriptionTab : Session -> PersonBody -> Element RecordMsg
viewDescriptionTab session body =
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
            , padding 20
            , spacing sectionSpacing
            ]
            (viewPersonSections
                { language = session.language
                , includeDigitalObjects = True
                , paragraphFormatter = viewMobileParagraphField
                , recordId = body.id
                , relationshipFormatter = viewMobileRelationshipBody
                , summaryFormatter = viewMobileSummaryField
                }
                body
            )
        ]
