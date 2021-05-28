module Page.Views.SearchPage.Previews exposing (..)

import Element exposing (Element, column, fill, height, none, row, text, width)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Components exposing (h5)


viewPreviewRouter : ServerData -> Language -> Element Msg
viewPreviewRouter previewData language =
    case previewData of
        SourceData body ->
            viewSourcePreview body language

        PersonData body ->
            viewPersonPreview body language

        _ ->
            viewUnknownPreview


viewSourcePreview : FullSourceBody -> Language -> Element Msg
viewSourcePreview body language =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill ]
                [ h5 language body.label ]
            , row
                [ width fill ]
                [ text body.id ]
            ]
        ]


viewPersonPreview : PersonBody -> Language -> Element Msg
viewPersonPreview body language =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill ]
                [ h5 language body.label ]
            , row
                [ width fill ]
                [ text body.id ]
            ]
        ]


viewUnknownPreview : Element Msg
viewUnknownPreview =
    none
