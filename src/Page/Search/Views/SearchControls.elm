module Page.Search.Views.SearchControls exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, maximum, minimum, none, row, scrollbarY, shrink, width)
import Language exposing (Language)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.SearchControls.Incipits exposing (viewFacetsForIncipitsMode)
import Page.Search.Views.SearchControls.Institutions exposing (viewFacetsForInstitutionsMode)
import Page.Search.Views.SearchControls.People exposing (viewFacetsForPeopleMode)
import Page.Search.Views.SearchControls.Sources exposing (viewFacetsForSourcesMode)


viewSearchControls : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
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
                    viewFacetsForPeopleMode language model body

                InstitutionsMode ->
                    viewFacetsForInstitutionsMode language model body

                LiturgicalFestivalsMode ->
                    none
    in
    row
        [ width (fill |> minimum 800)
        , height fill
        , scrollbarY
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ facetLayout
            ]
        ]
