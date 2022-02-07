module Page.Search.Views.Previews exposing (..)

import Element exposing (Element, alignLeft, alignRight, alignTop, centerY, column, el, fill, height, htmlAttribute, maximum, minimum, none, padding, pointer, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes
import Language exposing (Language)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.Search.Views.Previews.Incipit exposing (viewIncipitPreview)
import Page.Search.Views.Previews.Institution exposing (viewInstitutionPreview)
import Page.Search.Views.Previews.Person exposing (viewPersonPreview)
import Page.Search.Views.Previews.Source exposing (viewSourcePreview)
import Page.UI.Animations exposing (loadingBox)
import Page.UI.Attributes exposing (headingXS, searchColumnVerticalSize)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (ServerData(..))


viewPreviewRouter : Language -> ServerData -> Element SearchMsg
viewPreviewRouter language previewData =
    let
        preview =
            case previewData of
                SourceData body ->
                    viewSourcePreview language body

                PersonData body ->
                    viewPersonPreview language body

                InstitutionData body ->
                    viewInstitutionPreview language body

                IncipitData body ->
                    viewIncipitPreview language body

                _ ->
                    viewUnknownPreview
    in
    row
        [ width fill
        , height fill
        , searchColumnVerticalSize
        , scrollbarY
        , alignTop
        , alignRight
        , padding 20
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.color (colourScheme.black |> convertColorToElementColor)
        , Border.widthEach { left = 1, right = 0, top = 0, bottom = 0 }
        , htmlAttribute (Html.Attributes.style "z-index" "10")
        ]
        [ column
            [ width fill
            , spacing 10
            , alignTop
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , htmlAttribute (Html.Attributes.style "z-index" "10")
            ]
            [ viewRecordPreviewTitleBar
            , preview
            ]
        ]


viewRecordPreviewTitleBar : Element SearchMsg
viewRecordPreviewTitleBar =
    row
        [ width fill
        , height (px 30)
        , spacing 20
        ]
        [ el
            [ alignLeft
            , centerY
            , onClick UserClickedClosePreviewWindow
            , width (px 25)
            , height (px 25)
            , pointer
            ]
            (closeWindowSvg colourScheme.darkOrange)
        , el
            [ alignLeft
            , centerY
            , headingXS
            , Font.semiBold
            ]
            (text "Record preview")
        ]


viewUnknownPreview : Element msg
viewUnknownPreview =
    none
