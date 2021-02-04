module Records.Views exposing (..)

import Api.Records exposing (ApiResponse(..), InstitutionBody, PersonBody, RecordResponse(..), SourceBody)
import Element exposing (..)
import Element.Background as Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Html
import Language exposing (Language, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Model, Msg)
import UI.Style exposing (bodyFont, minMaxFill, renderTopBar, rismBlue)


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
    [ layout [ width fill, bodyFont ]
        (column [ centerX, width fill, height fill ]
            [ renderTopBar
            , renderContent model
            ]
        )
    ]


renderContent : Model -> Element Msg
renderContent model =
    let
        content =
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
    row [ width minMaxFill, height (fillPortion 15), centerX ]
        [ column [ width fill, height fill ]
            [ row [ width fill, height (fillPortion 15), alignLeft ] [ content ]
            ]
        ]


renderSource : SourceBody -> Language -> Element Msg
renderSource body language =
    column []
        [ row [ width fill, height (fillPortion 1) ]
            [ el [] (text (extractLabelFromLanguageMap language body.label))
            ]
        , row [ width fill, height (fillPortion 15) ] []
        ]


renderInstitution : InstitutionBody -> Language -> Element Msg
renderInstitution body language =
    column [] [ el [] (text (extractLabelFromLanguageMap language body.label)) ]


renderPerson : PersonBody -> Language -> Element Msg
renderPerson body language =
    column [ alignTop, width fill, height fill ]
        [ row [ width fill, height (fillPortion 2), centerY, Border.color (rgb255 193 125 65), Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 } ]
            [ el [ centerY, Font.size 24, Font.semiBold ] (text (extractLabelFromLanguageMap language body.label))
            ]
        , row [ width fill, height (fillPortion 1), centerY, Border.color (rgb255 255 198 110), Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 } ]
            [ el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Biographical Details")
            , el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Sources")
            , el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Secondary Literature")
            ]
        , row [ width fill, height (fillPortion 13), alignTop, paddingEach { bottom = 0, left = 0, right = 0, top = 20 } ]
            [ column []
                [ row [] []
                , row [] []
                ]
            ]
        ]
