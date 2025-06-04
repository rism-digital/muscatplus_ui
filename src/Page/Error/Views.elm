module Page.Error.Views exposing (..)

import Element exposing (Element, centerX, centerY, column, el, fill, link, paragraph, row, spacing, text, textColumn, width)
import Element.Font as Font
import Element.Region as Region
import Language exposing (Language, LanguageMap, dateFormatter)
import Page.RecordTypes.ApiError exposing (ApiError)
import Page.RecordTypes.Tombstone exposing (Tombstone)
import Page.UI.Attributes exposing (headingXL, lineSpacing, linkColour)
import Page.UI.Components exposing (h2, h3)
import Page.UI.Errors exposing (ErrorResponse(..))
import Time exposing (utc)


errorMessageView : Language -> ErrorResponse -> Element msg
errorMessageView language err =
    let
        specificErrorMessage =
            case err of
                BadUrlResponse { label } ->
                    viewGenericErrorResponse
                        { label = label
                        , language = language
                        }

                BadBodyResponse { label, description } ->
                    viewDescriptionErrorResponse
                        { description = description
                        , label = label
                        , language = language
                        }

                NotFoundResponse { label, errorMessage } ->
                    viewNotFoundResponse
                        { errorMessage = errorMessage
                        , label = label
                        , language = language
                        }

                BadRequestResponse { label, description } ->
                    viewDescriptionErrorResponse
                        { description = description
                        , label = label
                        , language = language
                        }

                GoneResponse { label, tombstone } ->
                    viewGoneResponse
                        { label = label
                        , language = language
                        , tombstone = tombstone
                        }

                OtherBadStatusResponse { label, description, statusCode } ->
                    viewDescriptionErrorResponse
                        { description = description
                        , label = label
                        , language = language
                        }

                NetworkErrorResponse { label } ->
                    viewGenericErrorResponse
                        { label = label
                        , language = language
                        }

                TimeoutErrorResponse { label } ->
                    viewGenericErrorResponse
                        { label = label
                        , language = language
                        }
    in
    row
        [ width fill
        , centerX
        , centerY
        , Region.mainContent
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , centerX
            ]
            specificErrorMessage
        ]


viewNotFoundResponse :
    { errorMessage : ApiError
    , label : LanguageMap
    , language : Language
    }
    -> List (Element msg)
viewNotFoundResponse { label, language, errorMessage } =
    [ row
        [ width fill
        , centerX
        , headingXL
        ]
        [ h2 language label ]
    , row
        [ width fill
        , centerX
        ]
        [ el [ Font.center ] (text errorMessage.message) ]
    ]


viewGoneResponse :
    { label : LanguageMap
    , language : Language
    , tombstone : Tombstone
    }
    -> List (Element msg)
viewGoneResponse { label, language, tombstone } =
    [ row
        [ centerX
        , centerY
        ]
        [ h2 language label ]
    , row
        [ centerX ]
        [ textColumn
            [ centerX
            , width fill
            ]
            [ paragraph
                [ Font.center ]
                [ el
                    [ Font.center ]
                    (text "This is a normal part of our editorial process.")
                ]
            , paragraph
                [ Font.center ]
                [ text "It may have been a duplicate of another record, or removed for another reason."
                , text "If you have any concerns please "
                , link
                    [ linkColour ]
                    { label = text "send us a message."
                    , url = "mailto:feedback@rism.online"
                    }
                ]
            , paragraph
                [ Font.center ]
                [ text "The last heading we have for this record is:" ]
            ]
        ]
    , row
        [ centerX
        , centerY
        ]
        [ h3 language tombstone.name
        ]
    , row
        [ centerY
        , centerX
        ]
        [ el [ Font.semiBold ] (text "Removed on: ")
        , el [] (text (dateFormatter utc tombstone.deleted))
        ]
    ]


viewGenericErrorResponse :
    { label : LanguageMap
    , language : Language
    }
    -> List (Element msg)
viewGenericErrorResponse { label, language } =
    [ h2 language label
    ]


viewDescriptionErrorResponse :
    { description : String
    , label : LanguageMap
    , language : Language
    }
    -> List (Element msg)
viewDescriptionErrorResponse { description, label, language } =
    [ h2 language label
    , paragraph
        [ Font.center
        ]
        [ text description ]
    ]
