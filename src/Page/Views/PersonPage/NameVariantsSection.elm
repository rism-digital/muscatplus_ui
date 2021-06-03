module Page.Views.PersonPage.NameVariantsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, row, spacing, width)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (NameVariantsSectionBody, PersonBody)
import Page.UI.Components exposing (h5, viewSummaryField)


viewNameVariantsRouter : PersonBody -> Language -> Element Msg
viewNameVariantsRouter body language =
    case body.nameVariants of
        Just nameVariantsSection ->
            viewNameVariantsSection nameVariantsSection language

        Nothing ->
            none


viewNameVariantsSection : NameVariantsSectionBody -> Language -> Element Msg
viewNameVariantsSection variantsSection language =
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
                [ width fill
                ]
                [ h5 language variantsSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                [ viewSummaryField variantsSection.items language ]
            ]
        ]
