module Mobile.Record.PublicationPage exposing (viewFullMobilePublicationPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, link, padding, paddingEach, px, row, scrollbarY, spacing, text, width)
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractLabelFromLanguageMapWithVariables, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Publication exposing (PublicationBody, WorkCatalogueStatus, WorksSectionBody)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), WorkResultBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (formatPublicationStatusBadge, pageBodyOrEmpty, viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (folderMusicSvg)
import Page.UI.Record.ContentsSection exposing (viewCreator)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordSearchResults)
import Page.UI.Record.TabShell exposing (TabSpec, descriptionTab, searchTab, selectBody, viewMobileTabBar)
import Page.UI.Search.MobileResults exposing (viewMobilePagedResults)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Search.SearchTemplate exposing (viewMobileSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobilePublicationPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
viewFullMobilePublicationPage session model body =
    let
        descriptionBody =
            viewDescriptionTab session body

        tabs =
            viewRecordTabs session model body descriptionBody

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                ]
                (folderMusicSvg colourScheme.darkBlue)
    in
    viewMobileRecordPage
        { session = session
        , body = body
        , icon = icon
        , topBar = viewMobileTabBar tabs
        , bodyView = (selectBody { bodyView = descriptionBody, showBottomShadow = True } tabs).bodyView
        }


viewDescriptionTab : Session -> PublicationBody -> Element RecordMsg
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
            , paddingEach { bottom = 90, left = 20, right = 20, top = 20 }
            , spacing sectionSpacing
            ]
            (pageBodyOrEmpty
                session.language
                False
                [ viewWorkCatalogueStatus session.language body.status
                , viewMaybe
                    (viewCreator
                        { language = session.language
                        , relationshipFormatter = viewMobileRelationshipBody
                        }
                    )
                    body.creator
                , Maybe.withDefault [] body.summary
                    |> viewMobileSummaryField session.language
                , viewMaybe
                    (viewRelationshipsSection
                        { language = session.language
                        , relationshipFormatter = viewMobileRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewNotesSection
                        { language = session.language
                        , paragraphFormatter = viewMobileParagraphField
                        }
                    )
                    body.notes
                , viewMaybe
                    (viewExternalResourcesSection
                        { language = session.language
                        , recordId = body.id
                        }
                    )
                    body.externalResources
                , viewMaybe (viewRelatedWorksCallout session.language) body.works
                ]
            )
        ]


viewWorksTabBody : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewWorksTabBody session model =
    viewRecordSearchResults
        { language = session.language
        , loadingView = viewMobileSearchResultsLoadingTmpl
        , loadedView = viewWorksSearchResultsSection session
        , response = model.searchResults
        }


viewRecordTabs :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
    -> List (TabSpec RecordMsg)
viewRecordTabs session model body descriptionBody =
    descriptionTab
        { bodyView = descriptionBody
        , currentTab = model.currentTab
        , language = session.language
        , recordId = body.id
        , showBottomShadow = True
        }
        :: (resolveSearchTabInfo model.searchResults body.works
                |> Maybe.map
                    (\searchInfo ->
                        searchTab
                            { bodyView = viewWorksTabBody session model
                            , currentTab = model.currentTab
                            , language = session.language
                            , searchUrl = searchInfo.searchUrl
                            , showBottomShadow = False
                            , tabLabel = localTranslations.works
                            , totalItems = searchInfo.totalItems
                            }
                    )
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
           )

viewWorksSearchResultsSection : Session -> SearchBody -> Element RecordMsg
viewWorksSearchResultsSection session body =
    let
        works =
            List.filterMap
                (\result ->
                    case result of
                        WorkResult work ->
                            Just work

                        _ ->
                            Nothing
                )
                body.items

        cards =
            if List.isEmpty works then
                [ text (extractLabelFromLanguageMap session.language localTranslations.noResultsHeader) ]

            else
                List.map (viewWorkSearchResultCard session.language) works
    in
    viewMobilePagedResults
        { bodyAttributes =
            [ paddingEach { bottom = 90, left = 20, right = 20, top = 20 }
            , spacing sectionSpacing
            ]
        , cards = cards
        , pagination = viewPagination session.language body.pagination RecordMsg.UserClickedSearchResultsPagination
        }


viewWorkSearchResultCard : Language -> WorkResultBody -> Element msg
viewWorkSearchResultCard language work =
    let
        catalogNumber =
            Maybe.withDefault "-" work.flags.catalogueIdentifier

        keyMode =
            Maybe.map (extractLabelFromLanguageMap language) work.flags.keyMode
                |> Maybe.withDefault "-"

        scoring =
            Maybe.withDefault "-" work.flags.scoringSummary

        sourcesInfo =
            case work.sources of
                Just sourceLink ->
                    link
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap language sourceLink.label)
                        , url = sourceLink.url
                        }

                Nothing ->
                    Maybe.map String.fromInt work.flags.numberOfSources
                        |> Maybe.withDefault "-"
                        |> text
    in
    row
        [ width fill
        , Border.width 1
        , Border.color colourScheme.midGrey
        , Border.rounded 4
        , padding 12
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ link
                [ linkColour
                , width fill
                , htmlAttribute (HA.style "overflow-wrap" "anywhere")
                ]
                { label = text (extractLabelFromLanguageMap language work.label)
                , url = work.id
                }
            , text ("Catalog number: " ++ catalogNumber)
            , text ("Key: " ++ keyMode)
            , text ("Scoring: " ++ scoring)
            , row [ spacing 5 ] [ text "Sources:", sourcesInfo ]
            ]
        ]


viewWorkCatalogueStatus : Language -> WorkCatalogueStatus -> Element msg
viewWorkCatalogueStatus language status =
    viewPreRenderedMobileSummaryField language
        [ { label = toLanguageMap "Status"
          , value = [ el [ alignTop ] (formatPublicationStatusBadge language status) ]
          }
        ]


viewRelatedWorksCallout : Language -> WorksSectionBody -> Element msg
viewRelatedWorksCallout language works =
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            [ text (extractLabelFromLanguageMap language works.sectionLabel)
            , link
                [ linkColour ]
                { label = text (extractLabelFromLanguageMap language localTranslations.seeAll)
                , url = works.url
                }
            , text
                (extractLabelFromLanguageMapWithVariables language
                    [ LanguageMapReplacementVariable "numItems" (String.fromInt works.totalItems) ]
                    localTranslations.showNumItems
                )
            ]
        ]
