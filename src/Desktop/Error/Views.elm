module Desktop.Error.Views exposing (view)

import Config as C
import Element exposing (Element, centerX, centerY, column, el, fill, height, link, none, padding, paragraph, px, row, spacing, text, width)
import Element.Background as Background
import Page.UI.Attributes exposing (headingSM, headingXL, lineSpacing, linkColour)
import Page.UI.Errors exposing (createErrorMessage)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (onlineTextSvg, rismLogo)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..))
import Session exposing (Session)


view :
    Session
    -> { a | response : Response data }
    -> Element msg
view session model =
    let
        errorMessages err =
            createErrorMessage session.language err

        errorMessage =
            case model.response of
                Error err ->
                    let
                        allMessages =
                            errorMessages err

                        mainMessage =
                            Tuple.first allMessages

                        otherMessage =
                            Tuple.second allMessages

                        otherMessageFmt strMsg =
                            el
                                [ headingSM
                                , centerX
                                , centerY
                                ]
                                (text strMsg)

                        otherMessageEl =
                            viewMaybe otherMessageFmt otherMessage
                    in
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
                                , centerX
                                , centerY
                                ]
                                (text mainMessage)
                            , otherMessageEl
                            ]
                        ]

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
                                (text "Nothing to see here.")
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
                    [ text "Please return to the "
                    , link [ linkColour ] { label = text "home page", url = C.serverUrl }
                    , text " and try again"
                    ]
                ]
            ]
        ]
