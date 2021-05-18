module Page.Views.SearchPage.Facets exposing (..)

import Element exposing (Element, alignLeft, centerX, el, fill, height, none, paddingXY, px, row, spacingXY, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (checkbox, labelLeft)
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg(..))
import Page.RecordTypes exposing (Facet, FacetItem)
import Page.Response exposing (ResultMode, parseStringToResultMode)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Images exposing (bookOpenSvg, institutionSvg, musicNotationSvg, peopleSvg, unknownSvg)
import Page.UI.Style exposing (colourScheme)


viewModeItems : ResultMode -> Facet -> Language -> Element Msg
viewModeItems selectedMode typeFacet language =
    row
        [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 1 }
        , Border.color colourScheme.red
        , centerX
        , width fill
        , height (px 60)
        ]
        (List.map (\t -> viewModeItem selectedMode t language) typeFacet.items)


viewModeItem : ResultMode -> FacetItem -> Language -> Element Msg
viewModeItem selectedMode fitem language =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        icon =
            case value of
                "sources" ->
                    bookOpenSvg

                "people" ->
                    peopleSvg

                "institutions" ->
                    institutionSvg

                "incipits" ->
                    musicNotationSvg

                _ ->
                    unknownSvg

        rowMode =
            parseStringToResultMode value

        baseRowStyle =
            [ alignLeft
            , Font.center
            , height fill
            , paddingXY 0 10
            , Border.widthEach { top = 0, left = 0, right = 0, bottom = 3 }
            ]

        rowStyle =
            if selectedMode == rowMode then
                Border.color colourScheme.red :: baseRowStyle

            else
                Border.color colourScheme.cream :: baseRowStyle
    in
    row
        rowStyle
        [ el [ paddingXY 5 0 ] icon
        , el []
            (checkbox
                [ alignLeft
                , spacingXY 20 0
                ]
                { onChange = \t -> ModeSelected "mode" fitem t
                , icon = \b -> none
                , checked = False
                , label =
                    labelLeft
                        [ bodyRegular
                        , alignLeft
                        ]
                        (text fullLabel)
                }
            )
        ]
