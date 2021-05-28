module Page.Views.SourcePage.PartOfSection exposing (..)

import Element exposing (Element, column, fill, link, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (FullSourceBody, PartOfSectionBody)
import Page.UI.Components exposing (h5)
import Page.UI.Style exposing (colourScheme)


viewPartOfRouter : FullSourceBody -> Language -> Element Msg
viewPartOfRouter body language =
    case body.partOf of
        Just partOfSection ->
            viewPartOfSection partOfSection language

        Nothing ->
            none


viewPartOfSection : PartOfSectionBody -> Language -> Element Msg
viewPartOfSection partOf language =
    let
        source =
            partOf.source
    in
    row
        [ width fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , spacing 10
            ]
            [ row
                [ width fill ]
                [ h5 language partOf.label ]
            , row
                [ width fill ]
                [ link
                    [ Font.color colourScheme.lightBlue ]
                    { url = source.id, label = text (extractLabelFromLanguageMap language source.label) }
                ]
            ]
        ]
