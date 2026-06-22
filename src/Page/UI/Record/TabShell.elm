module Page.UI.Record.TabShell exposing
    ( TabBody
    , TabSpec
    , descriptionTab
    , searchTab
    , selectBody
    , sourceSearchTabs
    , viewDesktopTabBar
    , viewMobileTabBar
    )

import Element exposing (Attribute, Element, alignBottom, alignLeft, centerY, fill, height, paddingEach, paddingXY, px, row, spacing, width)
import Language exposing (Language, LanguageMap)
import Page.Record.Model exposing (CurrentRecordViewTab(..))
import Page.Record.Msg exposing (RecordMsg)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordDescriptionTab, viewRecordSearchTab)
import Response exposing (Response, ServerData)


type alias TabBody msg =
    { bodyView : Element msg
    , showBottomShadow : Bool
    }


type alias TabSpec msg =
    { body : Maybe (TabBody msg)
    , isSelected : Bool
    , view : Element msg
    }


descriptionTab :
    { bodyView : Element RecordMsg
    , currentTab : CurrentRecordViewTab
    , language : Language
    , recordId : String
    , showBottomShadow : Bool
    }
    -> TabSpec RecordMsg
descriptionTab { bodyView, currentTab, language, recordId, showBottomShadow } =
    let
        isSelected =
            case currentTab of
                DefaultRecordViewTab _ ->
                    True

                _ ->
                    False
    in
    { body =
        Just
            { bodyView = bodyView
            , showBottomShadow = showBottomShadow
            }
    , isSelected = isSelected
    , view =
        viewRecordDescriptionTab
            { language = language
            , currentTab = currentTab
            , recordId = recordId
            }
    }


searchTab :
    { bodyView : Element RecordMsg
    , currentTab : CurrentRecordViewTab
    , language : Language
    , searchUrl : String
    , showBottomShadow : Bool
    , tabLabel : LanguageMap
    , totalItems : Int
    }
    -> TabSpec RecordMsg
searchTab { bodyView, currentTab, language, searchUrl, showBottomShadow, tabLabel, totalItems } =
    let
        isSelected =
            case currentTab of
                ContentsSearchDisplayTab _ ->
                    True

                _ ->
                    False
    in
    { body =
        Just
            { bodyView = bodyView
            , showBottomShadow = showBottomShadow
            }
    , isSelected = isSelected
    , view =
        viewRecordSearchTab
            { currentTab = currentTab
            , language = language
            , searchUrl = searchUrl
            , tabLabel = tabLabel
            , totalItems = totalItems
            }
    }


sourceSearchTabs :
    { bodyView : Element RecordMsg
    , currentTab : CurrentRecordViewTab
    , descriptionBodyView : Element RecordMsg
    , descriptionShowBottomShadow : Bool
    , fallbackBody : Maybe { a | url : String, totalItems : Int }
    , language : Language
    , recordId : String
    , searchResults : Response ServerData
    , searchShowBottomShadow : Bool
    , tabLabel : LanguageMap
    }
    -> List (TabSpec RecordMsg)
sourceSearchTabs { bodyView, currentTab, descriptionBodyView, descriptionShowBottomShadow, fallbackBody, language, recordId, searchResults, searchShowBottomShadow, tabLabel } =
    descriptionTab
        { bodyView = descriptionBodyView
        , currentTab = currentTab
        , language = language
        , recordId = recordId
        , showBottomShadow = descriptionShowBottomShadow
        }
        :: (resolveSearchTabInfo searchResults fallbackBody
                |> Maybe.map
                    (\searchInfo ->
                        searchTab
                            { bodyView = bodyView
                            , currentTab = currentTab
                            , language = language
                            , searchUrl = searchInfo.searchUrl
                            , showBottomShadow = searchShowBottomShadow
                            , tabLabel = tabLabel
                            , totalItems = searchInfo.totalItems
                            }
                    )
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
           )


selectBody : TabBody RecordMsg -> List (TabSpec RecordMsg) -> TabBody RecordMsg
selectBody fallback tabs =
    tabs
        |> List.filter .isSelected
        |> List.filterMap .body
        |> List.head
        |> Maybe.withDefault fallback


viewDesktopTabBar : List (TabSpec RecordMsg) -> Element RecordMsg
viewDesktopTabBar =
    viewTabBar
        [ width fill
        , height (px 35)
        , alignLeft
        , centerY
        , spacing 10
        ]


viewMobileTabBar : List (TabSpec RecordMsg) -> Element RecordMsg
viewMobileTabBar =
    viewTabBar
        [ width fill
        , height (px 35)
        , alignLeft
        , alignBottom
        , spacing 10
        , paddingEach { top = 0, right = 10, bottom = 4, left = 10 }
        ]


viewTabBar : List (Attribute RecordMsg) -> List (TabSpec RecordMsg) -> Element RecordMsg
viewTabBar attrs tabs =
    row attrs (List.map .view tabs)
