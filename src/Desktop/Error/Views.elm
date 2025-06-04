module Desktop.Error.Views exposing (view)

import Config as C
import Element exposing (Element, centerX, centerY, column, el, fill, height, link, none, padding, paragraph, px, row, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Font as Font
import Element.Region as Region
import Language exposing (Language, LanguageMap, dateFormatter, extractLabelFromLanguageMap, toLanguageMap)
import Page.Error.Views exposing (errorMessageView)
import Page.RecordTypes.ApiError exposing (ApiError)
import Page.RecordTypes.Tombstone exposing (Tombstone)
import Page.UI.Attributes exposing (headingXL, lineSpacing, linkColour)
import Page.UI.Components exposing (h1, h2, h3)
import Page.UI.Errors exposing (ErrorResponse(..), createErrorMessage)
import Page.UI.Images exposing (onlineTextSvg, rismLogo)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..))
import Session exposing (Session)
import Time exposing (utc)


view :
    Session
    -> { a | response : Response data }
    -> Element msg
view session model =
    let
        errorMessage =
            case model.response of
                Error err ->
                    createErrorMessage err
                        |> errorMessageView session.language

                NoResponseToShow ->
                    row
                        [ centerX
                        , centerY
                        ]
                        [ column
                            [ width fill
                            , spacing lineSpacing
                            ]
                            [ el
                                [ headingXL
                                , centerY
                                , centerX
                                ]
                                (text "This page has no content. This is likely an error.")
                            ]
                        ]

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
            , Background.color colourScheme.white
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
            , errorMessage
            , row
                [ centerX
                , centerY
                ]
                [ paragraph
                    [ width fill ]
                    [ text "Return to the "
                    , link [ linkColour ] { label = text "home page", url = C.serverUrl }
                    ]
                ]
            ]
        ]
