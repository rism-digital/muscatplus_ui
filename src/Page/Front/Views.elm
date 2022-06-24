module Page.Front.Views exposing (view)

import Element exposing (Element, alignLeft, alignTop, column, fill, height, maximum, minimum, none, padding, row, width)
import Element.Background as Background
import Element.Border as Border
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.IncipitSearch exposing (incipitSearchPanelView)
import Page.Front.Views.InstitutionSearch exposing (institutionSearchPanelView)
import Page.Front.Views.PeopleSearch exposing (peopleSearchPanelView)
import Page.Front.Views.SourceSearch exposing (sourceSearchPanelView)
import Page.SideBar.Msg exposing (SideBarOption(..))
import Page.UI.Attributes exposing (emptyAttribute)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Search.SearchComponents exposing (viewSearchButtons)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> FrontPageModel FrontMsg -> Element FrontMsg
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
        backgroundImage =
            case session.showFrontSearchInterface of
                SourceSearchOption ->
                    Background.image "/static/images/sources.jpg"

                PeopleSearchOption ->
                    Background.image "/static/images/people.jpg"

                InstitutionSearchOption ->
                    Background.image "/static/images/institutions.jpg"

                IncipitSearchOption ->
                    Background.image "/static/images/incipits.jpg"

                _ ->
                    emptyAttribute

        searchControlsView =
            viewMaybe
                (\_ ->
                    viewSearchButtons
                        { language = session.language
                        , model = model
                        , isFrontPage = True
                        , submitLabel = localTranslations.showResults
                        , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                        , resetMsg = FrontMsg.UserResetAllFilters
                        }
                )
                maybeBody

        -- viewMaybe will be either the searchViewFn, or the `none`
        -- element if the maybeBody parameter is Nothing.
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

        searchPanelView =
            viewMaybe searchViewFn maybeBody
    in
    row
        [ width fill
        , height fill
        , padding 20
        , backgroundImage
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , height fill
            , alignLeft
            , alignTop
            , Background.color (colourScheme.cream |> convertColorToElementColor)
            , Border.shadow
                { blur = 10
                , color =
                    colourScheme.darkGrey
                        |> convertColorToElementColor
                , offset = ( 1, 1 )
                , size = 1
                }
            ]
            [ searchControlsView
            , searchPanelView
            ]
        ]
