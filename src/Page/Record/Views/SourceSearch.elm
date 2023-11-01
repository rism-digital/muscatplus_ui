module Page.Record.Views.SourceSearch exposing
    ( viewRecordSourceSearchTabBar
    , viewSourceSearchTabBody
    )

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerY, clipY, column, el, fill, height, maximum, none, paddingXY, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Region as Region
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Error.Views exposing (createErrorMessage)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg(..))
import Page.Record.Views.Facets exposing (facetRecordMsgConfig)
import Page.RecordTypes.SourceRelationships exposing (SourceRelationshipsSectionBody)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingXL)
import Page.UI.Components exposing (h3)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, viewSearchResultsSection)
import Page.UI.Search.Templates.SearchTmpl exposing (viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewSourceSearchTabBody :
    Session
    -> RecordPageModel RecordMsg
    -> Element RecordMsg
viewSourceSearchTabBody session model =
    row
        [ width fill
        , height fill
        , alignTop
        , clipY
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ searchResultsViewRouter session model ]
        ]


searchResultsViewRouter :
    Session
    -> RecordPageModel RecordMsg
    -> Element RecordMsg
searchResultsViewRouter session model =
    let
        resultsConfig : SearchResultsSectionConfig (RecordPageModel RecordMsg) RecordMsg
        resultsConfig =
            { session = session
            , model = model
            , searchResponse = model.searchResults
            , expandedIncipitInfoSections = model.incipitInfoExpanded
            , userClosedPreviewWindowMsg = RecordMsg.UserClickedClosePreviewWindow
            , userClickedSourceItemsExpandMsg = RecordMsg.UserClickedExpandSourceItemsSectionInPreview
            , userClickedResultForPreviewMsg = RecordMsg.UserClickedSearchResultForPreview
            , userChangedResultSortingMsg = RecordMsg.UserChangedResultSorting
            , userChangedResultsPerPageMsg = RecordMsg.UserChangedResultsPerPage
            , userClickedResultsPaginationMsg = RecordMsg.UserClickedSearchResultsPagination
            , userTriggeredSearchSubmitMsg = RecordMsg.UserTriggeredSearchSubmit
            , userEnteredTextInKeywordQueryBoxMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
            , userResetAllFiltersMsg = RecordMsg.UserResetAllFilters
            , userRemovedActiveFilterMsg = RecordMsg.UserRemovedActiveFilter
            , userToggledIncipitInfo = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
            , panelToggleMsg = RecordMsg.UserClickedFacetPanelToggle
            , facetMsgConfig = facetRecordMsgConfig
            }
    in
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection resultsConfig True oldData

        Loading _ ->
            viewSearchResultsLoadingTmpl session.language

        Response (SearchData body) ->
            viewSearchResultsSection resultsConfig False body

        Error err ->
            createErrorMessage session.language err
                |> Tuple.first
                |> viewSearchResultsErrorTmpl session.language

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl session.language

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> viewSearchResultsErrorTmpl session.language


viewSourceSearchTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , searchUrl : String
    , tabLabel : LanguageMap
    }
    -> Element RecordMsg
viewSourceSearchTab { language, model, recordId, searchUrl, tabLabel } =
    let
        currentMode =
            model.currentTab

        localizedTabLabel =
            extractLabelFromLanguageMap language tabLabel

        sourceCount searchData =
            toFloat searchData.totalItems
                |> formatNumberByLanguage language

        ( searchTabBackground, searchTabFontColour ) =
            case currentMode of
                RelatedSourcesSearchTab _ ->
                    ( colourScheme.darkBlue
                    , colourScheme.white
                    )

                _ ->
                    ( colourScheme.white
                    , colourScheme.black
                    )

        sourceLabel =
            case model.searchResults of
                Loading _ ->
                    row
                        []
                        [ text localizedTabLabel
                        , animatedLoader
                            [ width (px 15)
                            , height (px 15)
                            ]
                            (spinnerSvg colourScheme.midGrey)
                        ]

                Response (SearchData searchData) ->
                    el
                        []
                        (localizedTabLabel
                            ++ " ("
                            ++ sourceCount searchData
                            ++ ")"
                            |> text
                        )

                _ ->
                    none
    in
    column
        [ height fill
        , pointer
        , Border.widthEach { bottom = 0, left = 2, right = 2, top = 2 }
        , Border.roundEach { bottomLeft = 0, bottomRight = 0, topLeft = 3, topRight = 3 }
        , Border.color colourScheme.darkBlue
        , Background.color searchTabBackground
        , Font.color searchTabFontColour
        , paddingXY 20 5
        , onClick (UserClickedRecordViewTab (RelatedSourcesSearchTab searchUrl))
        ]
        [ el
            [ headingXL
            , Region.heading 3
            , Font.medium
            , centerY
            ]
            sourceLabel
        ]


viewRecordSourceSearchTabBar :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , body : Maybe { a | url : String }
    , tabLabel : LanguageMap
    }
    -> Element RecordMsg
viewRecordSourceSearchTabBar { language, model, recordId, body, tabLabel } =
    let
        currentMode =
            model.currentTab

        sourceSearchTab =
            case body of
                Just s ->
                    viewSourceSearchTab
                        { language = language
                        , model = model
                        , recordId = recordId
                        , searchUrl = s.url
                        , tabLabel = tabLabel
                        }

                Nothing ->
                    none

        ( descriptionTabBackground, descriptionTabFontColour ) =
            case currentMode of
                DefaultRecordViewTab _ ->
                    ( colourScheme.darkBlue
                    , colourScheme.white
                    )

                _ ->
                    ( colourScheme.white
                    , colourScheme.black
                    )
    in
    row
        [ width (fill |> maximum 300)
        , height (px 35)
        , alignBottom
        , spacing 10
        , alignLeft
        ]
        [ column
            [ height fill
            , alignLeft
            , pointer
            , paddingXY 20 0
            , Border.widthEach { bottom = 0, left = 2, right = 2, top = 2 }
            , Border.roundEach { bottomLeft = 0, bottomRight = 0, topLeft = 3, topRight = 3 }
            , Border.color colourScheme.darkBlue
            , Background.color descriptionTabBackground
            , Font.color descriptionTabFontColour
            , onClick (UserClickedRecordViewTab (DefaultRecordViewTab recordId))
            ]
            [ el
                [ alignBottom
                , centerY
                ]
                (h3 language localTranslations.description)
            ]
        , sourceSearchTab
        ]
