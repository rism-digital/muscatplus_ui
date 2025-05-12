module Page.UI.Errors exposing (ErrorResponse(..), createErrorMessage, errorMessageString)

import Http.Detailed
import Json.Decode exposing (errorToString)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (errorMessages)
import Page.RecordTypes.Tombstone exposing (Tombstone, messageToTombstone)


type ErrorResponse
    = BadUrlResponse { label : LanguageMap }
    | BadBodyResponse { label : LanguageMap, description : String }
    | NotFoundResponse { label : LanguageMap, description : String }
    | BadRequestResponse { label : LanguageMap, description : String }
    | GoneResponse { label : LanguageMap, tombstone : Tombstone }
    | OtherBadStatusResponse { label : LanguageMap, description : String, statusCode : Int }
    | NetworkErrorResponse { label : LanguageMap }
    | TimeoutErrorResponse { label : LanguageMap }


createErrorMessage : Http.Detailed.Error String -> ErrorResponse
createErrorMessage error =
    case error of
        Http.Detailed.BadUrl url ->
            BadUrlResponse { label = toLanguageMap ("A Bad URL was supplied: " ++ url) }

        Http.Detailed.Timeout ->
            TimeoutErrorResponse
                { label = toLanguageMap "A timeout error response was received." }

        Http.Detailed.NetworkError ->
            NetworkErrorResponse
                { label = toLanguageMap "A problem with the network was detected."
                }

        Http.Detailed.BadStatus metadata message ->
            case metadata.statusCode of
                400 ->
                    BadRequestResponse
                        { label = errorMessages.badQuery
                        , description = message
                        }

                404 ->
                    NotFoundResponse
                        { label = errorMessages.notFound
                        , description = message
                        }

                410 ->
                    let
                        decodedMessage =
                            messageToTombstone message
                    in
                    case decodedMessage of
                        Ok ts ->
                            GoneResponse
                                { label = errorMessages.recordDeleted
                                , tombstone = ts
                                }

                        Err e ->
                            OtherBadStatusResponse
                                { label = toLanguageMap "A record is missing but no tombstone is available."
                                , description = errorToString e
                                , statusCode = metadata.statusCode
                                }

                _ ->
                    OtherBadStatusResponse
                        { label = toLanguageMap ("Response status code: " ++ String.fromInt metadata.statusCode)
                        , description = message
                        , statusCode = metadata.statusCode
                        }

        Http.Detailed.BadBody _ _ message ->
            BadBodyResponse
                { label = toLanguageMap "Unexpected response"
                , description = message
                }


errorMessageString : Language -> ErrorResponse -> String
errorMessageString language err =
    case err of
        BadUrlResponse { label } ->
            extractLabelFromLanguageMap language label

        BadBodyResponse { label } ->
            extractLabelFromLanguageMap language label

        NotFoundResponse { label } ->
            extractLabelFromLanguageMap language label

        BadRequestResponse { label } ->
            extractLabelFromLanguageMap language label

        GoneResponse { label } ->
            extractLabelFromLanguageMap language label

        OtherBadStatusResponse { label } ->
            extractLabelFromLanguageMap language label

        NetworkErrorResponse { label } ->
            extractLabelFromLanguageMap language label

        TimeoutErrorResponse { label } ->
            extractLabelFromLanguageMap language label
