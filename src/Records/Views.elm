module Records.Views exposing (..)

import Api.Records exposing (ApiResponse(..), RecordResponse(..))
import Element exposing (..)
import Element.Border as Border
import Html
import Records.DataTypes exposing (Model, Msg)


renderLoading : Model -> Element Msg
renderLoading model =
    column [ width fill, height fill ]
        [ row [ width fill, height fill ]
            [ el [ centerX, centerY ] (text "Loading") ]
        ]


renderError : Model -> Element Msg
renderError model =
    el [ centerX, centerY ] (text "Error")


renderBody : Model -> List (Html.Html Msg)
renderBody model =
    let
        body =
            case model.response of
                Loading ->
                    renderLoading model

                Response apiResponse ->
                    case apiResponse of
                        SourceResponse _ ->
                            renderSource model

                        PersonResponse _ ->
                            renderPerson model

                        InstitutionResponse _ ->
                            renderInstitution model

                ApiError ->
                    renderError model
    in
    [ layout [ width fill ]
        (column [ width (fill |> minimum 800 |> maximum 1200), centerX, height fill ]
            [ row [ width fill, height fill ]
                [ body ]
            ]
        )
    ]


renderSource : Model -> Element Msg
renderSource model =
    column [ width fill, height fill ] [ el [] (text "Source Record") ]


renderInstitution : Model -> Element Msg
renderInstitution model =
    el [ centerX, centerY ] (text "Institution Record!")


renderPerson : Model -> Element Msg
renderPerson model =
    el [ centerX, centerY ] (text "Person Record!")
