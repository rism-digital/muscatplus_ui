module Mobile.Record.InstitutionPage exposing (viewFullMobileInstitutionPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewSourceSearchTabBody)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewMobileParagraphField, viewMobileSummaryField)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.Bodies.Institution exposing (viewInstitutionSections)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Record.TabShell exposing (selectBody, sourceSearchTabs, viewMobileTabBar)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobileInstitutionPage :
    Session
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewFullMobileInstitutionPage session model body =
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
                (institutionSvg colourScheme.darkBlue)
    in
    viewMobileRecordPage
        { session = session
        , body = body
        , icon = icon
        , topBar = viewMobileTabBar tabs
        , bodyView = (selectBody { bodyView = descriptionBody, showBottomShadow = True } tabs).bodyView
        }


viewDescriptionTab : Session -> InstitutionBody -> Element RecordMsg
viewDescriptionTab session body =
    row
        [ width fill
        , height fill
        , alignTop
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
            (viewInstitutionSections
                { includeContributions = True
                , includeDigitalObjects = True
                , includeLocationMap = True
                , language = session.language
                , paragraphFormatter = viewMobileParagraphField
                , recordId = body.id
                , relationshipFormatter = viewMobileRelationshipBody
                , summaryFormatter = viewMobileSummaryField
                , window = session.window
                }
                body
            )
        ]
