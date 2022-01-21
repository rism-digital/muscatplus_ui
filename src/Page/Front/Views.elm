module Page.Front.Views exposing (..)

import Element exposing (Element, alignTop, centerX, column, fill, height, maximum, minimum, paddingXY, row, width)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg)
import Page.Front.Views.IncipitSearch exposing (incipitSearchPanelView)
import Page.Front.Views.InstiutionSearch exposing (institutionSearchPanelView)
import Page.Front.Views.PeopleSearch exposing (peopleSearchPanelView)
import Page.Front.Views.SourceSearch exposing (sourceSearchPanelView)
import Page.SideBar.Msg exposing (SideBarOption(..))
import Page.UI.Helpers exposing (viewMaybe)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> FrontPageModel -> Element FrontMsg
view session model =
    let
        maybeBody =
            case model.response of
                Response (FrontData body) ->
                    Just body

                _ ->
                    Nothing

        -- returns a partially-applied function that can be used in the viewMaybe
        -- for the body argument
        searchViewFn =
            case session.showFrontSearchInterface of
                SourceSearchOption ->
                    sourceSearchPanelView session model

                PeopleSearchOption ->
                    peopleSearchPanelView session model

                InstitutionSearchOption ->
                    institutionSearchPanelView session model

                IncipitSearchOption ->
                    incipitSearchPanelView session model

                -- For now, show the source panel if we ever find our way to this option.
                LiturgicalFestivalsOption ->
                    sourceSearchPanelView session model

        -- viewMaybe will be either the searchViewFn, or the `none`
        -- element if the maybeBody parameter is Nothing.
        searchPanelView =
            viewMaybe searchViewFn maybeBody
    in
    row
        [ width fill
        , height fill
        , centerX
        , paddingXY 20 100
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , centerX
            , alignTop
            ]
            [ searchPanelView
            ]
        ]
