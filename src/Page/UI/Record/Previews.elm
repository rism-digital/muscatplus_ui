module Page.UI.Record.Previews exposing (..)

import Element exposing (Element, alignLeft, alignRight, alignTop, centerY, clipY, column, el, fill, height, htmlAttribute, none, paddingXY, pointer, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.UI.Attributes exposing (headingMD, searchColumnVerticalSize)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)
import Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)
import Page.UI.Record.Previews.Person exposing (viewPersonPreview)
import Page.UI.Record.Previews.Source exposing (viewSourcePreview)
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
                    none
    in
    row
        [ width fill
        , height fill
        , clipY
        , alignTop
        , alignRight
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.color (colourScheme.lightBlue |> convertColorToElementColor)
        , Border.width 4
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
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