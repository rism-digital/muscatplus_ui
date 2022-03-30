module Page.Record.Views.InstitutionPage.LocationSection exposing (..)

import Array
import Element exposing (Element, alignTop, column, fill, height, link, none, paddingXY, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Institution exposing (CoordinatesSection, LocationAddressSectionBody)
import Page.RecordTypes.Shared exposing (LabelStringValue)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h2, h5, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


createCoordinatePair : List String -> ( Float, Float )
createCoordinatePair coordinateList =
    let
        coordinateArray =
            Array.fromList coordinateList

        latitude =
            Array.get 0 coordinateArray
                |> Maybe.withDefault "0"
                |> String.toFloat
                |> Maybe.withDefault 0

        longitude =
            Array.get 1 coordinateArray
                |> Maybe.withDefault "0"
                |> String.toFloat
                |> Maybe.withDefault 0
    in
    ( latitude, longitude )


viewLocationSection : CoordinatesSection -> Language -> Element msg
viewLocationSection body language =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill ]
                [ h5 language body.label ]
            ]
        ]


viewLocationAddressSection : Language -> LocationAddressSectionBody -> Element msg
viewLocationAddressSection language body =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill ]
                [ h2 language body.label ]
            , viewMaybe (viewSummaryField language) body.mailingAddress
            , viewMaybe (viewWebsiteAddress language) body.website
            , viewMaybe (viewEmailAddress language) body.email
            ]
        ]


viewWebsiteAddress : Language -> LabelStringValue -> Element msg
viewWebsiteAddress language websiteAddress =
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { url = websiteAddress.value
            , label = text websiteAddress.value
            }
        ]


viewEmailAddress : Language -> LabelStringValue -> Element msg
viewEmailAddress language emailAddress =
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { url = "mailto:" ++ emailAddress.value
            , label = text emailAddress.value
            }
        ]
