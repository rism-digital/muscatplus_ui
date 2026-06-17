module Desktop.Record.InstitutionPage exposing (viewFullInstitutionPage)

import Desktop.Record.PageShell exposing (TabBody, viewDesktopRecordPage)
import Desktop.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewParagraphField, viewSummaryField)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.Bodies.Institution exposing (viewInstitutionSections)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
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
        , chooseBody = chooseBody session model body
        , currentTab = model.currentTab
        , tabBar = viewRecordTopBar session.language model body
        }


chooseBody : Session -> RecordPageModel RecordMsg -> InstitutionBody -> CurrentRecordViewTab -> TabBody RecordMsg
chooseBody session model body currentTab =
    case currentTab of
        DefaultRecordViewTab _ ->
            { bodyView =
                viewDescriptionTab
                    { language = session.language }
                    session.window
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
                    { language = session.language }
                    session.window
                    body
            , showBottomShadow = True
            }


viewRecordTopBar :
    Language
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewRecordTopBar language model body =
    viewRecordSourceSearchTabBar
        { body = body.sources
        , language = language
        , model = model
        , recordId = body.id
        , tabLabel = localTranslations.sources
        }
