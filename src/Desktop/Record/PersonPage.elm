module Desktop.Record.PersonPage exposing (viewFullPersonPage)

import Desktop.Record.PageShell exposing (viewDesktopRecordPage)
import Desktop.Record.SourceSearch exposing (viewSourceSearchTabBody)
import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewParagraphField, viewSummaryField)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.Bodies.Person exposing (viewPersonSections)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.TabShell exposing (selectBody, sourceSearchTabs, viewDesktopTabBar)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewDescriptionTab : { language : Language } -> PersonBody -> Element msg
viewDescriptionTab { language } body =
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
            (viewPersonSections
                { language = language
                , includeDigitalObjects = True
                , paragraphFormatter = viewParagraphField
                , recordId = body.id
                , relationshipFormatter = viewRelationshipBody
                , summaryFormatter = viewSummaryField
                }
                body
            )
        ]


viewFullPersonPage :
    Session
    -> RecordPageModel RecordMsg
    -> PersonBody
    -> Element RecordMsg
viewFullPersonPage session model body =
    let
        descriptionBody =
            viewDescriptionTab
                { language = session.language }
                body

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
                , centerY
                ]
                (peopleSvg colourScheme.darkBlue)
    in
    viewDesktopRecordPage
        { session = session
        , body = body
        , icon = icon
        , selectedBody =
            selectBody
                { bodyView = descriptionBody
                , showBottomShadow = True
                }
                tabs
        , tabBar = viewDesktopTabBar tabs
        }
