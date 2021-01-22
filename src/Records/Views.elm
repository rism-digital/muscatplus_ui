module Records.Views exposing (..)

import Api.Records exposing (ApiResponse(..), InstitutionBody, PersonBody, RecordResponse(..), SourceBody)
import Element exposing (..)
import Html
import Language exposing (Language, extractLabelFromLanguageMap)
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
                        SourceResponse sourcebody ->
                            renderSource sourcebody model.language

                        PersonResponse personbody ->
                            renderPerson personbody model.language

                        InstitutionResponse institutionbody ->
                            renderInstitution institutionbody model.language

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


renderSource : SourceBody -> Language -> Element Msg
renderSource body language =
    column [ centerX, centerY ] [ el [] (text (extractLabelFromLanguageMap language body.label)) ]


renderInstitution : InstitutionBody -> Language -> Element Msg
renderInstitution body language =
    el [ centerX, centerY ] (text (extractLabelFromLanguageMap language body.label))


renderPerson : PersonBody -> Language -> Element Msg
renderPerson body language =
    el [ centerX, centerY ] (text (extractLabelFromLanguageMap language body.label))
