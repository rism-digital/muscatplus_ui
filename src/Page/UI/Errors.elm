module Page.UI.Errors exposing (createErrorMessage, createProbeErrorMessage)

import Http.Detailed
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (errorMessages)


createProbeErrorMessage : Http.Detailed.Error String -> String
createProbeErrorMessage error =
    ""


createErrorMessage : Language -> Http.Detailed.Error String -> ( String, Maybe String )
createErrorMessage language error =
    case error of
        Http.Detailed.BadUrl url ->
            ( "A Bad URL was supplied: " ++ url, Nothing )

        Http.Detailed.BadStatus metadata message ->
            case metadata.statusCode of
                400 ->
                    ( extractLabelFromLanguageMap language errorMessages.badQuery
                    , Just message
                    )

                404 ->
                    ( extractLabelFromLanguageMap language errorMessages.notFound
                    , Just message
                    )

                _ ->
                    ( "Response status code: " ++ String.fromInt metadata.statusCode
                    , Just message
                    )

        Http.Detailed.BadBody _ _ message ->
            ( "Unexpected response", Just message )

        _ ->
            ( "An unknown problem happened with the request", Nothing )
