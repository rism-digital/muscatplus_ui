module Page.Views.SearchPage.Facets exposing (..)

import Element exposing (Element, alignLeft, centerX, centerY, el, fill, height, none, padding, paddingXY, px, row, spacing, spacingXY, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (checkbox, labelLeft)
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Msg exposing (Msg(..))
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (Facet, FacetItem(..))
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Images exposing (bookOpenSvg, institutionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, unknownSvg)
import Page.UI.Style exposing (colourScheme)


viewModeItems : ResultMode -> Facet -> Language -> Element Msg
viewModeItems selectedMode typeFacet language =
    let
        rowLabel =
            row
                [ Font.semiBold
                , height fill
                , centerY
                ]
                [ text (extractLabelFromLanguageMap language typeFacet.label) ]
    in
    row
        [ centerX
        , width fill
        , height fill
        , height (px 40)
        , paddingXY 20 0
        , spacing 10
        , centerY
        ]
        (rowLabel :: List.map (\t -> viewModeItem selectedMode t language) typeFacet.items)


viewModeItem : ResultMode -> FacetItem -> Language -> Element Msg
viewModeItem selectedMode fitem language =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        iconTmpl svg =
            el
                [ width (px 16)
                , height fill
                , centerX
                , centerY
                ]
                svg

        icon =
            case value of
                "sources" ->
                    iconTmpl bookOpenSvg

                "people" ->
                    iconTmpl peopleSvg

                "institutions" ->
                    iconTmpl institutionSvg

                "incipits" ->
                    iconTmpl musicNotationSvg

                "festivals" ->
                    iconTmpl liturgicalFestivalSvg

                _ ->
                    iconTmpl unknownSvg

        rowMode =
            parseStringToResultMode value

        baseRowStyle =
            [ alignLeft
            , Font.center
            , Font.regular
            , height fill
            , Border.widthEach { top = 0, left = 0, bottom = 1, right = 0 }
            ]

        rowStyle =
            if selectedMode == rowMode then
                Border.color colourScheme.darkBlue :: baseRowStyle

            else
                Border.color colourScheme.cream :: baseRowStyle

        itemCount =
            formatNumberByLanguage count language
    in
    row
        rowStyle
        [ el [ paddingXY 5 0 ] icon
        , el []
            (checkbox
                [ alignLeft
                , spacing 10
                ]
                { onChange = \t -> ModeSelected "mode" fitem t
                , icon = \b -> none
                , checked = False
                , label =
                    labelLeft
                        [ bodyRegular
                        , alignLeft
                        ]
                        (text (fullLabel ++ " (" ++ itemCount ++ ")"))
                }
            )
        ]
