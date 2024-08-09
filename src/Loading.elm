module Loading exposing (loadingIndicator)

import Element exposing (Element, fill, htmlAttribute, none, row, width)
import Element.Keyed as Keyed
import Html.Attributes as HA
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.UI.Animations exposing (progressBar)
import Response exposing (Response(..))


loadingIndicator : Model -> Element Msg
loadingIndicator model =
    let
        chooseView resp =
            case resp of
                Loading _ ->
                    loadingView

                _ ->
                    Keyed.el [] ( "progress-bar-none", none )

        isLoading resp =
            case resp of
                Loading _ ->
                    True

                _ ->
                    False

        loadingView =
            row
                [ width fill
                , htmlAttribute (HA.style "z-index" "1")
                ]
                [ progressBar ]
    in
    case model of
        SearchPage _ pageModel ->
            if isLoading pageModel.response || isLoading pageModel.preview then
                loadingView

            else
                Keyed.el [] ( "progress-bar-none", none )

        FrontPage _ pageModel ->
            chooseView pageModel.response

        SourcePage _ pageModel ->
            chooseView pageModel.response

        PersonPage _ pageModel ->
            if List.any (\t -> isLoading t) [ pageModel.response, pageModel.searchResults, pageModel.preview ] then
                loadingView

            else
                Keyed.el [] ( "progress-bar-none", none )

        InstitutionPage _ pageModel ->
            if List.any (\t -> isLoading t) [ pageModel.response, pageModel.searchResults, pageModel.preview ] then
                loadingView

            else
                Keyed.el [] ( "progress-bar-none", none )

        _ ->
            none
