module Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)

import Config as C
import Element exposing (Element, alignBottom, alignTop, centerX, column, el, fill, height, image, minimum, newTabLink, padding, paragraph, px, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import List.Extra as LE
import Page.RecordTypes.DigitalObjects exposing (DigitalObject, DigitalObjectBody(..), DigitalObjectsSectionBody)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Helpers exposing (viewSVGRenderedIncipit)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewDigitalObjectThumbnail :
    Language
    -> { a | medium : String, original : String }
    -> DigitalObject
    -> Element msg
viewDigitalObjectThumbnail language imageUrls dObject =
    let
        description =
            extractLabelFromLanguageMap language dObject.label
    in
    column
        [ width (px 320)
        , height (fill |> minimum 320)
        , alignTop
        , spacing lineSpacing
        , Font.center
        , Border.width 1
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , padding 5
        ]
        [ newTabLink
            [ centerX ]
            { label =
                image
                    [ width fill
                    , height fill
                    ]
                    { description = description
                    , src = imageUrls.medium
                    }
            , url = imageUrls.original
            }
        , paragraph
            [ Font.center
            , width (px 300)
            , alignBottom
            ]
            [ newTabLink
                []
                { label = text description
                , url = imageUrls.original
                }
            ]
        ]


viewDigitalObjectRenderedNotation :
    Language
    -> { encoding : String, rendering : String }
    -> DigitalObject
    -> Element msg
viewDigitalObjectRenderedNotation language encoding dObject =
    let
        description =
            extractLabelFromLanguageMap language dObject.label

        svgNode =
            viewSVGRenderedIncipit encoding.rendering

        previewUrl =
            C.serverUrl ++ "/copperplate/copperplate.html?file=" ++ encoding.encoding
    in
    column
        [ width (px 320)
        , height (fill |> minimum 320)
        , alignTop
        , spacing lineSpacing
        , Font.center
        , Border.width 1
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , padding 5
        ]
        [ newTabLink
            [ width fill
            , height fill
            ]
            { label =
                el
                    [ width fill
                    , height fill
                    ]
                    svgNode
            , url = previewUrl
            }
        , paragraph
            [ Font.center
            , width (px 300)
            , alignBottom
            ]
            [ newTabLink
                []
                { label = text description
                , url = previewUrl
                }
            ]
        ]


viewDigitalObjectRouter : Language -> DigitalObject -> Element msg
viewDigitalObjectRouter language dObject =
    case dObject.body of
        ImageObject urls ->
            viewDigitalObjectThumbnail language urls dObject

        EncodingObject enc ->
            viewDigitalObjectRenderedNotation language enc dObject


viewDigitalObjectsSection : Language -> DigitalObjectsSectionBody -> Element msg
viewDigitalObjectsSection language doSection =
    let
        groupedItems =
            LE.greedyGroupsOf 3 doSection.items

        rowsOfItems =
            List.map
                (\rowItems ->
                    row
                        [ width fill
                        , alignTop
                        , spacing 20
                        ]
                        (List.map
                            (viewDigitalObjectRouter language)
                            rowItems
                        )
                )
                groupedItems

        sectionBody =
            [ row
                [ width fill ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing 20
                    ]
                    rowsOfItems
                ]
            ]
    in
    sectionTemplate language doSection sectionBody
