module Page.Views.SourcePage.ContentsSection exposing (..)

import Element exposing (Element, column, fill, htmlAttribute, none, paddingXY, row, spacing, width)
import Html.Attributes as HTA
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (ContentsSectionBody, FullSourceBody)
import Page.UI.Components exposing (h5, viewSummaryField)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewContentsSection : Language -> ContentsSectionBody -> Element Msg
viewContentsSection language contents =
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
            , viewMaybe (viewRelationshipBody language) contents.creator
            , Maybe.withDefault [] contents.summary
                |> viewSummaryField language
            ]
        ]
