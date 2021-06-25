module Page.Views.SearchPage.Previews exposing (..)

import Element exposing (Element, alignLeft, alignRight, alignTop, column, el, fill, height, none, padding, pointer, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language)
import Msg exposing (Msg(..))
import Page.Response exposing (ServerData(..))
import Page.UI.Animations exposing (loadingBox)
import Page.UI.Attributes exposing (headingXS)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.SearchPage.Previews.Incipit exposing (viewIncipitPreview)
import Page.Views.SearchPage.Previews.Institution exposing (viewInstitutionPreview)
import Page.Views.SearchPage.Previews.Person exposing (viewPersonPreview)
import Page.Views.SearchPage.Previews.Source exposing (viewSourcePreview)


viewPreviewRouter : Language -> ServerData -> Element Msg
viewPreviewRouter language previewData =
    let
        preview =
            case previewData of
                SourceData body ->
                    viewSourcePreview body language

                PersonData body ->
                    viewPersonPreview body language

                InstitutionData body ->
                    viewInstitutionPreview body language

                IncipitData body ->
                    viewIncipitPreview body language

                _ ->
                    viewUnknownPreview
    in
    row
        [ width fill
        , height fill
        , scrollbarY
        , alignTop
        , padding 20
        , Background.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , spacing 10
            , alignTop
            ]
            [ viewRecordPreviewTitleBar
            , preview
            ]
        ]


viewRecordPreviewTitleBar : Element Msg
viewRecordPreviewTitleBar =
    row
        [ width fill
        , height (px 40)
        ]
        [ el
            [ alignLeft
            , alignTop
            , headingXS
            , Font.semiBold
            ]
            (text "Record preview")
        , el
            [ alignRight
            , alignTop
            , onClick UserClickedClosePreviewWindow
            , width (px 25)
            , height (px 25)
            , pointer
            ]
            (closeWindowSvg colourScheme.darkGrey)
        ]


viewPreviewLoading : Element Msg
viewPreviewLoading =
    row
        [ width fill
        , height fill
        , scrollbarY
        , alignTop
        , padding 20
        , Background.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
            ]
            [ viewRecordPreviewTitleBar
            , row
                []
                [ loadingBox 800 50 ]
            , row [] [ loadingBox 700 200 ]
            , row [] [ loadingBox 700 200 ]
            , row [] [ loadingBox 700 200 ]
            , row [] [ loadingBox 700 200 ]
            , row [] [ loadingBox 700 200 ]
            , row [] [ loadingBox 700 200 ]
            ]
        ]


viewUnknownPreview : Element Msg
viewUnknownPreview =
    none
