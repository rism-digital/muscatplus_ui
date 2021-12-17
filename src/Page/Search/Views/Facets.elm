module Page.Search.Views.Facets exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, none, paddingXY, pointer, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (checkbox, labelLeft)
import Element.Region as Region
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Page.Query exposing (Filter(..))
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetBehaviours(..), FacetData(..), FacetItem(..), FacetSorts(..), ModeFacet, QueryFacet, RangeFacet, SearchBody, SelectFacet, ToggleFacet)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.Search.Views.Facets.NotationFacet exposing (viewKeyboardControl)
import Page.Search.Views.Facets.QueryFacet exposing (viewQueryFacet)
import Page.Search.Views.Facets.RangeFacet exposing (viewRangeFacet)
import Page.Search.Views.Facets.SelectFacet exposing (viewSelectFacet)
import Page.Search.Views.Facets.ToggleFacet exposing (viewToggleFacet)
import Page.UI.Attributes exposing (facetBorderBottom, headingMD, headingSM, lineSpacing, widthFillHeightFill)
import Page.UI.Images exposing (chevronDownSvg, institutionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, sourcesSvg, unknownSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewModeItems : ResultMode -> Language -> ModeFacet -> Element SearchMsg
viewModeItems selectedMode language typeFacet =
    let
        rowLabel =
            row
                [ Font.medium
                , height fill
                , centerY
                , headingSM
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


viewModeItem : ResultMode -> Language -> FacetItem -> Element SearchMsg
viewModeItem selectedMode language fitem =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        iconTmpl svg =
            el
                [ width (px 20)
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
            , height fill
            , Border.widthEach { top = 0, left = 0, bottom = 1, right = 0 }
            ]

        rowStyle =
            if selectedMode == rowMode then
                Border.color (colourScheme.darkBlue |> convertColorToElementColor) :: baseRowStyle

            else
                Border.color (colourScheme.cream |> convertColorToElementColor) :: baseRowStyle

        itemCount =
            formatNumberByLanguage language count
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
                        [ headingSM
                        , alignLeft
                        ]
                        (text (fullLabel ++ " (" ++ itemCount ++ ")"))
                }
            )
        ]


viewFacetSection :
    Language
    -> String
    -> List (Element SearchMsg)
    -> Element SearchMsg
viewFacetSection language title facets =
    row
        (List.concat [ widthFillHeightFill, facetBorderBottom ])
        [ column
            (List.append [ spacing lineSpacing, alignTop ] widthFillHeightFill)
            [ row
                (List.append [ spacing lineSpacing ] widthFillHeightFill)
                [ column
                    [ alignLeft ]
                    [ el
                        [ alignLeft
                        , width (px 10)
                        , pointer
                        , onClick NothingHappened -- TODO: Implement collapsing behaviour!
                        ]
                        (chevronDownSvg colourScheme.lightBlue)
                    ]
                , column
                    [ headingMD, Region.heading 3, Font.medium, alignLeft ]
                    [ text title ]
                ]
            , row
                (List.append [ alignTop ] widthFillHeightFill)
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    facets
                ]
            ]
        ]


viewFacet : String -> Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewFacet facetKey language activeSearch body =
    let
        facetDict =
            body.facets

        facetConf =
            Dict.get facetKey facetDict

        query =
            activeSearch.nextQuery

        activeFilters =
            query.filters
    in
    case facetConf of
        Just (ToggleFacetData facet) ->
            viewToggleFacet language activeFilters facet

        Just (RangeFacetData facet) ->
            viewRangeFacet language activeFilters facet

        Just (SelectFacetData facet) ->
            let
                facetSorts =
                    query.facetSorts

                expandedFacets =
                    activeSearch.expandedFacets

                facetConfig =
                    { facetSorts = facetSorts
                    , activeFilters = activeFilters
                    , expandedFacets = expandedFacets
                    }
            in
            viewSelectFacet language facetConfig facet

        Just (NotationFacetData facet) ->
            let
                activeKeyboard =
                    activeSearch.keyboard
            in
            viewKeyboardControl language activeKeyboard

        Just (QueryFacetData facet) ->
            viewQueryFacet language facet activeSearch

        _ ->
            none
