module Page.Front.Views exposing (..)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, maximum, minimum, paddingXY, row, text, width)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg)
import Page.Front.Views.SourceSearch exposing (sourceSearchPanelRouter, sourceSearchPanelView)
import Page.SideBar.Msg exposing (SideBarOption(..))
import Page.UI.Attributes exposing (headingXL)
import Session exposing (Session)


view : Session -> FrontPageModel -> Element FrontMsg
view session model =
    let
        bodyView =
            case session.showFrontSearchInterface of
                SourceSearchOption ->
                    sourceSearchFrontPage session model

                PeopleSearchOption ->
                    peopleSearchFrontPage

                InstitutionSearchOption ->
                    institutionSearchFrontPage

                IncipitSearchOption ->
                    incipitSearchFrontPage
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
            [ row
                [ width fill ]
                []
            , bodyView
            ]
        ]


sourceSearchFrontPage : Session -> FrontPageModel -> Element FrontMsg
sourceSearchFrontPage session model =
    row
        [ width fill
        , centerX
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ sourceSearchPanelRouter session model ]
        ]


peopleSearchFrontPage : Element msg
peopleSearchFrontPage =
    row
        [ width fill
        , centerX
        ]
        [ el [ headingXL ] (text "People search") ]


institutionSearchFrontPage : Element msg
institutionSearchFrontPage =
    row
        [ width fill
        , centerX
        ]
        [ el [ headingXL ] (text "Institution search") ]


incipitSearchFrontPage : Element msg
incipitSearchFrontPage =
    row
        [ width fill
        , centerX
        ]
        [ el [ headingXL ] (text "Incipit search") ]
