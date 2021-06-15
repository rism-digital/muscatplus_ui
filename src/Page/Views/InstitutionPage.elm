module Page.Views.InstitutionPage exposing (..)

import Element exposing (Element, column, fill, height, none, padding, row, width)
import Element.Background as Background
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.Response exposing (ServerData(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.InstitutionPage.FullRecordPage exposing (viewFullInstitutionPage)


view : Model -> Element Msg
view model =
    let
        page =
            model.page

        response =
            page.response

        pageView =
            case response of
                Loading ->
                    none

                Response (InstitutionData body) ->
                    viewFullInstitutionPage model.page model.language body

                Error _ ->
                    -- TODO: Show error page
                    none

                _ ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , Background.color (colourScheme.white |> convertColorToElementColor)
            ]
            [ pageView ]
        ]
