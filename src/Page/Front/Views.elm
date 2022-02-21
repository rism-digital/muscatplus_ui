module Page.Front.Views exposing (..)

import Element exposing (Element, alignTop, centerX, column, fill, height, maximum, minimum, none, padding, paddingXY, row, width)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg)
import Page.Front.Views.IncipitSearch exposing (incipitSearchPanelView)
import Page.Front.Views.InstitutionSearch exposing (institutionSearchPanelView)
import Page.Front.Views.PeopleSearch exposing (peopleSearchPanelView)
import Page.Front.Views.SearchControls exposing (viewFrontSearchButtons)
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

                -- Show a blank page if this is ever the choice; it shouldn't be!
                LiturgicalFestivalsOption ->
                    \_ -> none

        -- viewMaybe will be either the searchViewFn, or the `none`
        -- element if the maybeBody parameter is Nothing.
        searchPanelView =
            viewMaybe searchViewFn maybeBody
    in
    row
        [ width fill
        , height fill
        , centerX
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , height fill
            , centerX
            , alignTop
            ]
            [ searchPanelView
            , viewFrontSearchButtons session.language model
            ]
        ]
