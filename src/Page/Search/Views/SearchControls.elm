module Page.Search.Views.SearchControls exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, none, row, width)
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.SearchControls.Incipits exposing (viewFacetsForIncipitsMode)
import Page.Search.Views.SearchControls.Institutions exposing (facetsForInstitutionsModeView)
import Page.Search.Views.SearchControls.People exposing (facetsForPeopleModeView)
import Page.Search.Views.SearchControls.Sources exposing (viewFacetsForSourcesMode)
import Page.UI.Search.SearchComponents exposing (viewSearchButtons)


viewSearchControls : Language -> SearchPageModel SearchMsg -> SearchBody -> Element SearchMsg
viewSearchControls language model body =
    let
        currentMode =
            toActiveSearch model
                |> toNextQuery
                |> toMode

        facetLayout =
            case currentMode of
                IncipitsMode ->
                    viewFacetsForIncipitsMode language model body

                SourcesMode ->
                    viewFacetsForSourcesMode language model body

                PeopleMode ->
                    facetsForPeopleModeView language model body

                InstitutionsMode ->
                    facetsForInstitutionsModeView language model body

                LiturgicalFestivalsMode ->
                    none
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
            [ viewSearchButtons
                { language = language
                , model = model
                , isFrontPage = False
                , submitLabel = localTranslations.updateResults
                , submitMsg = SearchMsg.UserTriggeredSearchSubmit
                , resetMsg = SearchMsg.UserResetAllFilters
                }
            , facetLayout
            ]
        ]
