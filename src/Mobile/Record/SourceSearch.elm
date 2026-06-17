module Mobile.Record.SourceSearch exposing
    ( viewRecordDescriptionTab
    , viewRecordSourceSearchTabBar
    , viewSourceSearchTabBody
    )

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, link, none, padding, paddingEach, px, row, scrollbarY, spacing, text, width)
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.PartOf exposing (extractUrlAndLabelFromPartOf)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), SourceResultBody)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing)
import Page.UI.Components exposing (Tab(..), tabView)
import Page.UI.Errors exposing (errorMessageString)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewSourceSearchTabBody : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewSourceSearchTabBody session model =
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


viewRecordSourceSearchTabBar :
    { body : Maybe { a | url : String, totalItems : Int }
    , language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , tabLabel : LanguageMap
    }
    -> Element RecordMsg
viewRecordSourceSearchTabBar { body, language, model, recordId, tabLabel } =
    row
        [ width fill
        , height (px 35)
        , alignLeft
        , alignBottom
        , spacing 10
        , Element.paddingXY 10 0
        ]
        [ viewRecordDescriptionTab
            { language = language
            , model = model
            , recordId = recordId
            }
        , viewMaybe
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
                    , tabLabel = tabLabel
                    , sourcesCount = sourceCount
                    }
            )
            body
        ]


viewSourcesDisplayTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , searchUrl : String
    , tabLabel : LanguageMap
    , sourcesCount : Int
    }
    -> Element RecordMsg
viewSourcesDisplayTab { language, model, searchUrl, tabLabel, sourcesCount } =
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
        , tab = CountTab tabLabel (Just sourcesCount)
        }


viewRecordDescriptionTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    }
    -> Element RecordMsg
viewRecordDescriptionTab { language, model, recordId } =
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
