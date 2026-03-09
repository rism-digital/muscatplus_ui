module Mobile.Record.WorkPage exposing (viewFullMobileWorkPage)

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, link, none, padding, paddingEach, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.PartOf exposing (extractUrlAndLabelFromPartOf)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), SourceResultBody)
import Page.RecordTypes.Work exposing (FormOfWorkSectionBody, WorkBody)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing)
import Page.UI.Components exposing (Tab(..), pageBodyOrEmpty, tabView, viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Errors exposing (errorMessageString)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (spinnerSvg, userMusicSvg)
import Page.UI.Record.ContentsSection exposing (viewCreator)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewWorkPartOfCatalogueSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewFullMobileWorkPage :
    Session
    -> RecordPageModel RecordMsg
    -> WorkBody
    -> Element RecordMsg
viewFullMobileWorkPage session model body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (userMusicSvg colourScheme.darkBlue)

        pageBodyView =
            case model.currentTab of
                ContentsSearchDisplayTab _ ->
                    viewSourcesTabBody session model

                _ ->
                    viewDescriptionTab session model body
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


viewDescriptionTab : Session -> RecordPageModel RecordMsg -> WorkBody -> Element RecordMsg
viewDescriptionTab session model body =
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
                [ viewMaybe (viewWorkPartOfCatalogueSection session.language) body.partOf
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
                    (viewFormOfWorkSection
                        { language = session.language
                        , preRenderedFormatter = viewPreRenderedMobileSummaryField
                        }
                    )
                    body.formOfWork
                , viewMaybe
                    (viewRelationshipsSection
                        { language = session.language
                        , relationshipFormatter = viewMobileRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewIncipitsSection
                        { language = session.language
                        , infoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , expandedIncipits = model.incipitInfoExpanded
                        , summaryFormatter = viewMobileSummaryField
                        }
                    )
                    body.incipits
                , viewMaybe
                    (viewReferencesNotesSection
                        { language = session.language
                        , paragraphFormatter = viewMobileParagraphField
                        , preRenderedFormatter = viewPreRenderedMobileSummaryField
                        }
                    )
                    body.referencesNotes
                , viewMaybe
                    (viewExternalResourcesSection
                        { language = session.language
                        , recordId = body.id
                        }
                    )
                    body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection session.language) body.externalAuthorities
                ]
            )
        ]


viewSourcesTabBody : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewSourcesTabBody session model =
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewSourcesSearchResultsSection session oldData

        Loading _ ->
            viewMobileSourcesLoading

        Response (SearchData body) ->
            viewSourcesSearchResultsSection session body

        Error err ->
            errorMessageString session.language err
                |> text

        NoResponseToShow ->
            viewMobileSourcesLoading

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> text


viewRecordTopBar : Language -> RecordPageModel RecordMsg -> WorkBody -> Element RecordMsg
viewRecordTopBar language model body =
    let
        workDescriptionTab =
            viewWorkDescriptionTab
                { language = language
                , model = model
                , recordId = body.id
                }

        sourcesTab =
            viewMaybe
                (\s ->
                    let
                        ( searchUrl, sourceCount ) =
                            case model.searchResults of
                                Loading (Just (SearchData data)) ->
                                    ( data.id, data.totalItems )

                                Response (SearchData data) ->
                                    ( data.id, data.totalItems )

                                _ ->
                                    ( s.url, s.totalItems )
                    in
                    viewSourcesDisplayTab
                        { language = language
                        , model = model
                        , searchUrl = searchUrl
                        , sourcesCount = sourceCount
                        }
                )
                body.sources
    in
    row
        [ width fill
        , height (px 35)
        , alignLeft
        , alignBottom
        , spacing 10
        , paddingXY 10 0
        ]
        [ workDescriptionTab
        , sourcesTab
        ]


viewSourcesDisplayTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , searchUrl : String
    , sourcesCount : Int
    }
    -> Element RecordMsg
viewSourcesDisplayTab { language, model, searchUrl, sourcesCount } =
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
        , tab = CountTab localTranslations.sources (Just sourcesCount)
        }


viewWorkDescriptionTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    }
    -> Element RecordMsg
viewWorkDescriptionTab { language, model, recordId } =
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


viewMobileSourcesLoading : Element msg
viewMobileSourcesLoading =
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


viewSourcesSearchResultsSection : Session -> SearchBody -> Element RecordMsg
viewSourcesSearchResultsSection session body =
    let
        sources =
            List.filterMap
                (\result ->
                    case result of
                        SourceResult source ->
                            Just source

                        _ ->
                            Nothing
                )
                body.items

        cards =
            if List.isEmpty sources then
                [ text (extractLabelFromLanguageMap session.language localTranslations.noResultsHeader) ]

            else
                List.map (viewSourceSearchResultCard session.language) sources
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
                    , paddingEach { bottom = 90, left = 20, right = 20, top = 20 }
                    , spacing sectionSpacing
                    ]
                    cards
                ]
            , viewPagination session.language body.pagination RecordMsg.UserClickedSearchResultsPagination
            ]
        ]


viewSourceSearchResultCard : Language -> SourceResultBody -> Element msg
viewSourceSearchResultCard language source =
    let
        partOfLabel =
            case source.partOf of
                Just partOf ->
                    partOf.items
                        |> List.head
                        |> Maybe.map (\it -> extractUrlAndLabelFromPartOf it.relatedTo |> Tuple.second)
                        |> Maybe.map (extractLabelFromLanguageMap language)
                        |> Maybe.withDefault ""

                Nothing ->
                    ""

        sourceTypeLabel =
            Maybe.map (\flags -> extractLabelFromLanguageMap language flags.sourceType.label) source.flags
                |> Maybe.withDefault ""
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
                { label = text (extractLabelFromLanguageMap language source.label)
                , url = source.id
                }
            , text sourceTypeLabel
            , text partOfLabel
            ]
        ]


viewFormOfWorkSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : Language.LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> FormOfWorkSectionBody
    -> Element msg
viewFormOfWorkSection { language, preRenderedFormatter } formOfWorkSection =
    preRenderedFormatter language
        [ { label = formOfWorkSection.label
          , value = List.map (\it -> text (extractLabelFromLanguageMap language it.label)) formOfWorkSection.items
          }
        ]
