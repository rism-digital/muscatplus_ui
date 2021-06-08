module Page.Views.SourcePage.ContentsSection exposing (..)

import Element exposing (Element, column, fill, htmlAttribute, none, paddingXY, row, spacing, width)
import Html.Attributes as HTA
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (ContentsSectionBody, FullSourceBody)
import Page.UI.Components exposing (h5, viewSummaryField)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewContentsRouter : FullSourceBody -> Language -> Element Msg
viewContentsRouter body language =
    case body.contents of
        Just contentsSection ->
            viewContentsSection contentsSection language

        Nothing ->
            none


viewContentsSection : ContentsSectionBody -> Language -> Element Msg
viewContentsSection contents language =
    let
        summary =
            Maybe.withDefault [] contents.summary

        creator =
            case contents.creator of
                Just relBody ->
                    viewRelationshipBody relBody language

                Nothing ->
                    none
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
                [ width fill
                , htmlAttribute (HTA.id contents.sectionToc)
                ]
                [ h5 language contents.label ]
            , creator
            , viewSummaryField summary language
            ]
        ]
