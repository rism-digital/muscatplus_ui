module Page.UI.Search.Results.WorkResult exposing (viewWorkSearchResult)

import Element exposing (Element, text)
import Page.RecordTypes.Search exposing (WorkResultBody)
import Page.UI.Search.Results exposing (SearchResultConfig)


viewWorkSearchResult :
    SearchResultConfig msg
    -> WorkResultBody
    -> Element msg
viewWorkSearchResult { language, selectedResult, clickForPreviewMsg, resultIdx } body =
    text "Work result"
