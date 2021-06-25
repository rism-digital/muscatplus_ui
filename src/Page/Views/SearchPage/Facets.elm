module Page.Views.SearchPage.Facets exposing (..)

import Dict
import Element exposing (Element, alignLeft, centerX, centerY, column, el, fill, height, none, paddingXY, px, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (checkbox, labelLeft)
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Msg exposing (Msg(..))
import Page.Query exposing (Filter(..))
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetData(..), FacetItem(..), FilterFacet, ModeFacet, RangeFacet, SearchBody, SelectorFacet, ToggleFacet)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Images exposing (institutionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, sourcesSvg, unknownSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Search exposing (ActiveSearch)


viewModeItems : ResultMode -> Language -> ModeFacet -> Element Msg
viewModeItems selectedMode language typeFacet =
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
        , height (px 40)
        , paddingXY 20 0
        , spacing 10
        , centerY
        ]
        (rowLabel :: List.map (\t -> viewModeItem selectedMode language t) typeFacet.items)


viewModeItem : ResultMode -> Language -> FacetItem -> Element Msg
viewModeItem selectedMode language fitem =
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
                    iconTmpl (sourcesSvg colourScheme.slateGrey)

                "people" ->
                    iconTmpl (peopleSvg colourScheme.slateGrey)

                "institutions" ->
                    iconTmpl (institutionSvg colourScheme.slateGrey)

                "incipits" ->
                    iconTmpl (musicNotationSvg colourScheme.slateGrey)

                "festivals" ->
                    iconTmpl (liturgicalFestivalSvg colourScheme.slateGrey)

                _ ->
                    iconTmpl (unknownSvg colourScheme.slateGrey)

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
                Border.color (colourScheme.darkBlue |> convertColorToElementColor) :: baseRowStyle

            else
                Border.color (colourScheme.cream |> convertColorToElementColor) :: baseRowStyle

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
                { onChange = \t -> UserClickedModeItem "mode" fitem t
                , icon = \_ -> none
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


viewFacet : String -> Language -> ActiveSearch -> SearchBody -> Element Msg
viewFacet facetKey language activeSearch body =
    let
        facetDict =
            body.facets

        facetConf =
            Dict.get facetKey facetDict

        query =
            activeSearch.query

        activeFilters =
            query.filters

        facetView =
            case facetConf of
                Just (ToggleFacetData facet) ->
                    viewToggleFacet language activeFilters facet

                Just (RangeFacetData facet) ->
                    viewRangeFacet language activeFilters facet

                _ ->
                    none
    in
    facetView


viewToggleFacet : Language -> List Filter -> ToggleFacet -> Element Msg
viewToggleFacet language activeFilters facet =
    let
        facetAlias =
            facet.alias

        isActive =
            List.any (\(Filter alias _) -> alias == facetAlias) activeFilters
    in
    row
        []
        [ column
            []
            [ row
                []
                [ el []
                    (Toggle.view isActive (UserClickedFacetToggle facet.alias)
                        |> Toggle.setLabel (extractLabelFromLanguageMap language facet.label)
                        |> Toggle.render
                    )
                ]
            ]
        ]


viewRangeFacet : Language -> List Filter -> RangeFacet -> Element Msg
viewRangeFacet language activeFilters body =
    row
        []
        [ el [] (text "Range facet!") ]


viewSelectorFacet : Language -> List Filter -> SelectorFacet -> Element Msg
viewSelectorFacet language activeFilters body =
    none


viewFilterFacet : Language -> List Filter -> FilterFacet -> Element Msg
viewFilterFacet language activeFilters body =
    none
