module Mobile.Record.PublicationPage exposing (viewFullMobilePublicationPage)

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, link, none, padding, paddingEach, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractLabelFromLanguageMapWithVariables, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Publication exposing (PublicationBody, WorkCatalogueStatus, WorksSectionBody)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), WorkResultBody)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (Tab(..), formatPublicationStatusBadge, pageBodyOrEmpty, tabView, viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Errors exposing (errorMessageString)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (folderMusicSvg, spinnerSvg)
import Page.UI.Record.ContentsSection exposing (viewCreator)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewFullMobilePublicationPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
viewFullMobilePublicationPage session model body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (folderMusicSvg colourScheme.darkBlue)

        pageBodyView =
            case model.currentTab of
                ContentsSearchDisplayTab _ ->
                    viewWorksTabBody session model

                _ ->
                    viewDescriptionTab session body
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
                , paddingXY 10 10
                ]
                [ mobilePageHeaderTemplate session.language (Just icon) body ]
            , viewRecordTopBar session.language model body
            , pageBodyView
            ]
        ]


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
            , paddingEach { top = 20, right = 20, bottom = 90, left = 20 }
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
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewWorksSearchResultsSection session oldData

        Loading _ ->
            viewMobileWorksLoading

        Response (SearchData body) ->
            viewWorksSearchResultsSection session body

        Error err ->
            errorMessageString session.language err
                |> text

        NoResponseToShow ->
            viewMobileWorksLoading

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> text


viewRecordTopBar : Language -> RecordPageModel RecordMsg -> PublicationBody -> Element RecordMsg
viewRecordTopBar language model body =
    let
        publicationDescriptionTab =
            viewPublicationDescriptionTab
                { language = language
                , model = model
                , recordId = body.id
                }

        worksDisplayTab =
            viewMaybe
                (\s ->
                    let
                        ( searchUrl, worksCount ) =
                            case model.searchResults of
                                Loading (Just (SearchData data)) ->
                                    ( data.id, data.totalItems )

                                Response (SearchData data) ->
                                    ( data.id, data.totalItems )

                                _ ->
                                    ( s.url, s.totalItems )
                    in
                    viewWorksDisplayTab
                        { language = language
                        , model = model
                        , searchUrl = searchUrl
                        , tabLabel = localTranslations.works
                        , worksCount = worksCount
                        }
                )
                body.works
    in
    row
        [ width fill
        , height (px 35)
        , alignLeft
        , alignBottom
        , spacing 10
        , paddingXY 10 0
        ]
        [ publicationDescriptionTab
        , worksDisplayTab
        ]


viewWorksDisplayTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , searchUrl : String
    , tabLabel : Language.LanguageMap
    , worksCount : Int
    }
    -> Element RecordMsg
viewWorksDisplayTab { language, model, searchUrl, tabLabel, worksCount } =
    let
        isSelected =
            case model.currentTab of
                ContentsSearchDisplayTab _ ->
                    True

                _ ->
                    False

        tabMsg =
            if isSelected then
                RecordMsg.NothingHappened

            else
                RecordMsg.UserClickedRecordViewTab (ContentsSearchDisplayTab searchUrl)
    in
    tabView
        { clickMsg = tabMsg
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = CountTab tabLabel (Just worksCount)
        }


viewPublicationDescriptionTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    }
    -> Element RecordMsg
viewPublicationDescriptionTab { language, model, recordId } =
    let
        isSelected =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    True

                _ ->
                    False

        tabMsg =
            if isSelected then
                RecordMsg.NothingHappened

            else
                RecordMsg.UserClickedRecordViewTab (DefaultRecordViewTab recordId)
    in
    tabView
        { clickMsg = tabMsg
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = BareTab localTranslations.description
        }


viewMobileWorksLoading : Element msg
viewMobileWorksLoading =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ el
            [ width (px 50)
            , height (px 50)
            , centerX
            , centerY
            ]
            (animatedLoader
                [ width (px 50)
                , height (px 50)
                ]
                (spinnerSvg colourScheme.lightBlue)
            )
        ]


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
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , height fill
                , alignTop
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , alignTop
                    , paddingEach { top = 20, right = 20, bottom = 90, left = 20 }
                    , spacing sectionSpacing
                    ]
                    cards
                ]
            , viewPagination session.language body.pagination RecordMsg.UserClickedSearchResultsPagination
            ]
        ]


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
