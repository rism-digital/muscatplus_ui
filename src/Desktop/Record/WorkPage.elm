module Desktop.Record.WorkPage exposing (viewFullWorkPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Work exposing (FormOfWorkSectionBody, WorkBody)
import Page.UI.Attributes exposing (minimalDropShadow, sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.ContentsSection exposing (viewCreator)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Session exposing (Session)


viewFullWorkPage :
    Session
    -> RecordPageModel RecordMsg
    -> WorkBody
    -> Element RecordMsg
viewFullWorkPage session model body =
    let
        headerHeight =
            px (recordTitleHeight + searchSourcesLinkHeight)

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (peopleSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplate session.language (Just icon) body

        language =
            session.language

        pageBodyView =
            pageBodyOrEmpty
                session.language
                False
                [ viewMaybe
                    (viewCreator
                        { language = language
                        , relationshipFormatter = viewRelationshipBody
                        }
                    )
                    body.creator
                , Maybe.withDefault [] body.summary
                    |> viewSummaryField language
                , viewMaybe
                    (viewFormOfWorkSection
                        { language = language
                        , preRenderedFormatter = viewPreRenderedSummaryField
                        }
                    )
                    body.formOfWork
                , viewMaybe
                    (viewRelationshipsSection
                        { language = language
                        , relationshipFormatter = viewRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewIncipitsSection
                        { language = language
                        , infoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , expandedIncipits = model.incipitInfoExpanded
                        , summaryFormatter = viewSummaryField
                        }
                    )
                    body.incipits
                ]
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ row
                [ width fill
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.midGrey
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , minimalDropShadow
                    ]
                    [ pageHeader
                    ]
                ]
            , row
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
                    pageBodyView
                ]
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewFormOfWorkSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> FormOfWorkSectionBody
    -> Element msg
viewFormOfWorkSection { language, preRenderedFormatter } formOfWorkSection =
    preRenderedFormatter language
        [ { label = formOfWorkSection.label
          , value = List.map (\it -> text (extractLabelFromLanguageMap language it.label)) formOfWorkSection.items
          }
        ]
