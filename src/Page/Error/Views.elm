module Page.Error.Views exposing (createErrorMessage, createProbeErrorMessage, view)

import Config as C
import Element exposing (Element, centerX, centerY, column, el, fill, height, link, moveUp, none, padding, paragraph, px, row, spacing, text, width)
import Element.Background as Background
import Http.Detailed
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (errorMessages)
import Page.UI.Attributes exposing (headingLG, headingXL, linkColour)
import Page.UI.Images exposing (onlineTextSvg, rismLogo)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData)
import Session exposing (Session)


createProbeErrorMessage : Http.Detailed.Error String -> String
createProbeErrorMessage error =
    ""


createErrorMessage : Language -> Http.Detailed.Error String -> String
createErrorMessage language error =
    case error of
        Http.Detailed.BadUrl url ->
            "A Bad URL was supplied: " ++ url

        Http.Detailed.BadStatus metadata message ->
            case metadata.statusCode of
                404 ->
                    extractLabelFromLanguageMap language errorMessages.notFound

                _ ->
                    "Unknown status"

        Http.Detailed.BadBody _ _ message ->
            "Unexpected response: " ++ message

        _ ->
            "A problem happened with the request"


view :
    Session
    -> { a | response : Response data }
    -> Element msg
view session model =
    let
        errorMessage =
            case model.response of
                Error err ->
                    el
                        [ headingXL ]
                        (createErrorMessage session.language err
                            |> text
                        )

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
            , spacing 10
            , Background.color (colourScheme.white |> convertColorToElementColor)
            ]
            [ row
                [ centerX
                , centerY
                , spacing 10
                ]
                [ column
                    []
                    [ rismLogo colourScheme.darkBlue 100 ]
                , column
                    []
                    [ el
                        [ width (px 180)
                        , height (px 37)
                        , centerY
                        ]
                        (onlineTextSvg colourScheme.darkBlue)
                    ]
                ]
            , row
                [ centerX
                , centerY
                ]
                [ errorMessage ]
            , row
                [ centerX
                , centerY
                ]
                [ paragraph
                    [ width fill ]
                    [ text "Please return to the "
                    , link [ linkColour ] { url = C.serverUrl, label = text "home page" }
                    , text " and try again"
                    ]
                ]
            ]
        ]
