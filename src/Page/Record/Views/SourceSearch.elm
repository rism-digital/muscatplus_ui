module Page.Record.Views.SourceSearch exposing
    ( viewRecordSourceSearchTabBar
    , viewRecordTopBarDescriptionOnly
    , viewSourceSearchTab
    )

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, none, pointer, px, row, shrink, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg(..))
import Page.Record.Views.Facets exposing (facetRecordMsgConfig)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingSM)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, viewSearchResultsSection)
import Page.UI.Search.Templates.SearchTmpl exposing (viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewSourceSearchTab :
    Session
    -> RecordPageModel RecordMsg
    -> Element RecordMsg
viewSourceSearchTab session model =
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
            , userClosedPreviewWindowMsg = RecordMsg.UserClickedClosePreviewWindow
            , userClickedResultForPreviewMsg = RecordMsg.UserClickedSearchResultForPreview
            , userChangedResultSortingMsg = RecordMsg.UserChangedResultSorting
            , userChangedResultsPerPageMsg = RecordMsg.UserChangedResultsPerPage
            , userClickedResultsPaginationMsg = RecordMsg.UserClickedSearchResultsPagination
            , userTriggeredSearchSubmitMsg = RecordMsg.UserTriggeredSearchSubmit
            , userEnteredTextInKeywordQueryBoxMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
            , userResetAllFiltersMsg = RecordMsg.UserResetAllFilters
            , facetMsgConfig = facetRecordMsgConfig
            , sectionToggleMsg = RecordMsg.NothingHappened
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
            viewSearchResultsErrorTmpl session.language err

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl session.language

        _ ->
            viewSearchResultsErrorTmpl session.language "An unknown error occurred."


viewRecordSourceSearchTabBar :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , searchUrl : String
    , tabLabel : LanguageMap
    }
    -> Element RecordMsg
viewRecordSourceSearchTabBar { language, model, recordId, searchUrl, tabLabel } =
    let
        currentMode =
            model.currentTab

        descriptionTabBorder =
            case currentMode of
                DefaultRecordViewTab _ ->
                    colourScheme.lightBlue |> convertColorToElementColor

                _ ->
                    colourScheme.cream |> convertColorToElementColor

        localizedTabLabel =
            extractLabelFromLanguageMap language tabLabel

        searchTabBorder =
            case currentMode of
                RelatedSourcesSearchTab _ ->
                    colourScheme.lightBlue |> convertColorToElementColor

                _ ->
                    colourScheme.cream |> convertColorToElementColor

        sourceCount searchData =
            toFloat searchData.totalItems
                |> formatNumberByLanguage language

        sourceLabel =
            case model.searchResults of
                Loading _ ->
                    row
                        [ spacing 5 ]
                        [ text localizedTabLabel
                        , animatedLoader
                            [ width (px 15), height (px 15) ]
                            (spinnerSvg colourScheme.slateGrey)
                        ]

                Response (SearchData searchData) ->
                    row
                        [ spacing 5 ]
                        [ localizedTabLabel
                            ++ " ("
                            ++ sourceCount searchData
                            ++ ")"
                            |> text
                        ]

                _ ->
                    none
    in
    row
        [ centerX
        , width fill
        , height (px 25)
        , spacing 15
        ]
        [ el
            [ width shrink
            , height fill
            , Font.center
            , alignLeft
            , pointer
            , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
            , Border.color descriptionTabBorder
            ]
            (button
                []
                { label = text (extractLabelFromLanguageMap language localTranslations.description)
                , onPress = Just (UserClickedRecordViewTab (DefaultRecordViewTab recordId))
                }
            )
        , el
            [ width shrink
            , height fill
            , alignLeft
            , centerY
            , pointer
            , headingSM
            , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
            , Border.color searchTabBorder
            ]
            (button
                []
                { label = sourceLabel
                , onPress = Just (UserClickedRecordViewTab (RelatedSourcesSearchTab searchUrl))
                }
            )
        ]


viewRecordTopBarDescriptionOnly : Element msg
viewRecordTopBarDescriptionOnly =
    -- TODO: Translate label
    row
        [ centerX
        , width fill
        , height (px 25)
        , spacing 15
        ]
        [ el
            [ width shrink
            , height fill
            , Font.center
            , alignLeft
            , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
            , Border.color (colourScheme.lightBlue |> convertColorToElementColor)
            ]
            (text "Description")
        ]
