module Page.UI.Record.SearchTabs exposing
    ( resolveSearchTabInfo
    , viewRecordDescriptionTab
    , viewRecordSearchResults
    , viewRecordSearchTab
    )

import Element exposing (Element, none, text)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..))
import Page.Record.Msg exposing (RecordMsg(..))
import Page.RecordTypes.Search exposing (SearchBody)
import Page.UI.Components exposing (Tab(..), tabView)
import Page.UI.Errors exposing (errorMessageString)
import Response exposing (Response(..), ServerData(..))


resolveSearchTabInfo :
    Response ServerData
    -> Maybe { a | url : String, totalItems : Int }
    -> Maybe { searchUrl : String, totalItems : Int }
resolveSearchTabInfo searchResults fallbackBody =
    case searchResults of
        Loading (Just (SearchData data)) ->
            Just
                { searchUrl = data.id
                , totalItems = data.totalItems
                }

        Response (SearchData data) ->
            Just
                { searchUrl = data.id
                , totalItems = data.totalItems
                }

        _ ->
            Maybe.map
                (\body ->
                    { searchUrl = body.url
                    , totalItems = body.totalItems
                    }
                )
                fallbackBody


viewRecordDescriptionTab :
    { language : Language
    , currentTab : CurrentRecordViewTab
    , recordId : String
    }
    -> Element RecordMsg
viewRecordDescriptionTab { language, currentTab, recordId } =
    let
        isSelected =
            case currentTab of
                DefaultRecordViewTab _ ->
                    True

                _ ->
                    False

        clickMsg =
            if isSelected then
                NothingHappened

            else
                UserClickedRecordViewTab (DefaultRecordViewTab recordId)
    in
    tabView
        { clickMsg = clickMsg
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = BareTab localTranslations.description
        }


viewRecordSearchTab :
    { currentTab : CurrentRecordViewTab
    , language : Language
    , searchUrl : String
    , tabLabel : LanguageMap
    , totalItems : Int
    }
    -> Element RecordMsg
viewRecordSearchTab { currentTab, language, searchUrl, tabLabel, totalItems } =
    let
        isSelected =
            case currentTab of
                ContentsSearchDisplayTab _ ->
                    True

                _ ->
                    False

        clickMsg =
            if isSelected then
                NothingHappened

            else
                UserClickedRecordViewTab (ContentsSearchDisplayTab searchUrl)
    in
    tabView
        { clickMsg = clickMsg
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = CountTab tabLabel (Just totalItems)
        }


viewRecordSearchResults :
    { language : Language
    , loadingView : Element msg
    , loadedView : SearchBody -> Element msg
    , response : Response ServerData
    }
    -> Element msg
viewRecordSearchResults { language, loadingView, loadedView, response } =
    case response of
        Loading (Just (SearchData oldData)) ->
            loadedView oldData

        Loading _ ->
            loadingView

        Response (SearchData body) ->
            loadedView body

        Error err ->
            text (errorMessageString language err)

        NoResponseToShow ->
            loadingView

        _ ->
            text (extractLabelFromLanguageMap language localTranslations.unknownError)
