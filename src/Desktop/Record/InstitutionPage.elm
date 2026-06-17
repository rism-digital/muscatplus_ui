module Desktop.Record.InstitutionPage exposing (viewFullInstitutionPage)

import Desktop.Record.PageShell exposing (viewDesktopRecordPage)
import Desktop.Record.SourceSearch exposing (viewSourceSearchTabBody)
import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewParagraphField, viewSummaryField)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.Bodies.Institution exposing (viewInstitutionSections)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.TabShell exposing (selectBody, sourceSearchTabs, viewDesktopTabBar)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewDescriptionTab : { language : Language } -> ( Int, Int ) -> InstitutionBody -> Element msg
viewDescriptionTab { language } ( windowWidth, windowHeight ) body =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            , padding 20
            ]
            (viewInstitutionSections
                { includeContributions = True
                , includeDigitalObjects = True
                , includeLocationMap = True
                , language = language
                , paragraphFormatter = viewParagraphField
                , recordId = body.id
                , relationshipFormatter = viewRelationshipBody
                , summaryFormatter = viewSummaryField
                , window = ( windowWidth, windowHeight )
                }
                body
            )
        ]


viewFullInstitutionPage :
    Session
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewFullInstitutionPage session model body =
    let
        descriptionBody =
            viewDescriptionTab
                { language = session.language }
                session.window
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
                (institutionSvg colourScheme.darkBlue)
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
