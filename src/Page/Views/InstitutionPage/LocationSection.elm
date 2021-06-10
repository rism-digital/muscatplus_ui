module Page.Views.InstitutionPage.LocationSection exposing (..)

import Array
import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Institution exposing (LocationSectionBody)
import Page.UI.Components exposing (h5)


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


viewLocationSection : LocationSectionBody -> Language -> Element msg
viewLocationSection body language =
    let
        ( latitude, longitude ) =
            createCoordinatePair body.coordinates
    in
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
