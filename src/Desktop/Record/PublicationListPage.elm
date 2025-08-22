module Desktop.Record.PublicationListPage exposing (viewPublicationListPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, fillPortion, height, htmlAttribute, indexedTable, link, padding, paddingXY, paragraph, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Publication exposing (PublicationBasic, PublicationBody)
import Page.RecordTypes.PublicationList exposing (PublicationListBody)
import Page.RecordTypes.Relationship exposing (RelatedToBody)
import Page.RecordTypes.Shared exposing (LabelStringValue)
import Page.UI.Attributes exposing (cycleTableBackground, linkColour, minimalDropShadow, sectionSpacing, tableHeaderStyles)
import Page.UI.Images exposing (folderMusicSvg)
import Page.UI.Record.PageTemplate exposing (pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, tableCellPadding)
import Session exposing (Session)


viewPublicationListPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationListBody
    -> Element RecordMsg
viewPublicationListPage session model body =
    let
        headerHeight =
            px recordTitleHeight

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (folderMusicSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplate session.language (Just icon) body
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
                    , padding 20
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    [ indexedTable
                        [ Border.width 1
                        , Border.color colourScheme.midGrey
                        ]
                        { columns =
                            [ { header = el tableHeaderStyles (text "Composer")
                              , width = fillPortion 2
                              , view = \i w -> viewComposerCell session.language i w.composer
                              }
                            , { header = el tableHeaderStyles (text "Short Title")
                              , width = fillPortion 1
                              , view = \i w -> viewShortTitleCell session.language i w
                              }
                            , { header = el tableHeaderStyles (text "Catalog Title")
                              , width = fillPortion 4
                              , view = \i w -> viewCatalogTitleCell session.language i w
                              }
                            , { header = el tableHeaderStyles (text "Publication Year")
                              , width = fillPortion 1
                              , view = \i w -> viewPublicationYearCell session.language i w
                              }
                            , { header = el tableHeaderStyles (text "Status")
                              , width = fillPortion 1
                              , view = \i w -> viewStatusCell session.language i w.status
                              }
                            ]
                        , data = body.items
                        }
                    ]
                ]
            ]
        ]


viewShortTitleCell : Language -> Int -> PublicationBasic -> Element RecordMsg
viewShortTitleCell language rowNum publication =
    let
        cellBg =
            cycleTableBackground rowNum

        shortTitle =
            Maybe.map .shortTitle publication.properties
                |> ME.join
                |> Maybe.map (extractLabelFromLanguageMap language)
                |> Maybe.withDefault ""
    in
    link
        [ cellBg, linkColour, padding tableCellPadding, height fill ]
        { label = paragraph [ centerY ] [ text shortTitle ]
        , url = publication.id
        }


viewPublicationYearCell : Language -> Int -> PublicationBasic -> Element RecordMsg
viewPublicationYearCell language rowNum publication =
    let
        cellBg =
            cycleTableBackground rowNum

        publicationDates =
            Maybe.map .publicationDates publication.properties
                |> ME.join
                |> Maybe.map (extractLabelFromLanguageMap language)
                |> Maybe.withDefault ""
    in
    el
        [ cellBg, padding tableCellPadding, height fill ]
        (paragraph [ centerY ] [ text publicationDates ])


viewCatalogTitleCell : Language -> Int -> PublicationBasic -> Element RecordMsg
viewCatalogTitleCell language rowNum publication =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    el
        [ cellBg, padding tableCellPadding, height fill ]
        (paragraph [ centerY ]
            [ extractLabelFromLanguageMap language publication.label
                |> text
            ]
        )


viewComposerCell : Language -> Int -> Maybe RelatedToBody -> Element RecordMsg
viewComposerCell language rowNum composer =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    case composer of
        Just c ->
            el
                [ cellBg, padding tableCellPadding, height fill ]
                (paragraph
                    [ centerY ]
                    [ text (extractLabelFromLanguageMap language c.label) ]
                )

        Nothing ->
            el
                [ cellBg, padding tableCellPadding, height fill ]
                (paragraph [ centerY ] [ text "[No composer]" ])


viewStatusCell : Language -> Int -> LabelStringValue -> Element RecordMsg
viewStatusCell language rowNum status =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    el
        [ cellBg, padding tableCellPadding, height fill ]
        (paragraph [ centerY ]
            [ extractLabelFromLanguageMap language status.label
                |> text
            ]
        )
