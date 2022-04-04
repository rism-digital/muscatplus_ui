module Page.Search.Views.Previews exposing (..)

import Element exposing (Element, alignLeft, alignRight, alignTop, centerY, column, el, fill, height, htmlAttribute, none, paddingXY, pointer, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Search.Views.Previews.Incipit exposing (viewIncipitPreview)
import Page.Search.Views.Previews.Institution exposing (viewInstitutionPreview)
import Page.Search.Views.Previews.Person exposing (viewPersonPreview)
import Page.Search.Views.Previews.Source exposing (viewSourcePreview)
import Page.UI.Attributes exposing (headingMD, searchColumnVerticalSize)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (ServerData(..))


viewPreviewRouter : Language -> msg -> ServerData -> Element msg
viewPreviewRouter language closeMsg previewData =
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
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.color (colourScheme.lightBlue |> convertColorToElementColor)
        , Border.width 4
        , htmlAttribute (Html.Attributes.style "z-index" "10")
        ]
        [ column
            [ width fill
            , spacing 10
            , alignTop
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , htmlAttribute (Html.Attributes.style "z-index" "10")
            ]
            [ viewRecordPreviewTitleBar language closeMsg
            , preview
            ]
        ]


viewRecordPreviewTitleBar : Language -> msg -> Element msg
viewRecordPreviewTitleBar language closeMsg =
    row
        [ width fill
        , height (px 30)
        , spacing 10
        , paddingXY 10 20
        , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
        , Border.color (colourScheme.darkBlue |> convertColorToElementColor)
        , Background.color (colourScheme.lightBlue |> convertColorToElementColor)
        ]
        [ el
            [ alignLeft
            , centerY
            , onClick closeMsg
            , width (px 25)
            , height (px 25)
            , pointer
            ]
            (closeWindowSvg colourScheme.white)
        , el
            [ alignLeft
            , centerY
            , headingMD
            , Font.semiBold
            , Font.color (colourScheme.white |> convertColorToElementColor)
            ]
            (text <| extractLabelFromLanguageMap language localTranslations.recordPreview)
        ]


viewUnknownPreview : Element msg
viewUnknownPreview =
    none
