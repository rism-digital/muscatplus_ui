module Page.Search.Views.Facets exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, none, paddingXY, pointer, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (checkbox, labelLeft)
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetBehaviours(..), FacetData(..), FacetItem(..), FacetSorts(..), Facets, ModeFacet, QueryFacet, RangeFacet, SearchBody, SelectFacet, ToggleFacet)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.Search.Views.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)
import Page.Search.Views.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)
import Page.Search.Views.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)
import Page.Search.Views.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)
import Page.Search.Views.Facets.ToggleFacet exposing (ToggleFacetConfig, viewToggleFacet)
import Page.UI.Attributes exposing (facetBorderBottom, headingSM, lineSpacing, widthFillHeightFill)
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
    -> List (Element SearchMsg)
    -> Element SearchMsg
viewFacetSection language facets =
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
                ]
            , row
                (List.append [ alignTop ] widthFillHeightFill)
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    facets
                ]
            ]
        ]


viewFacet :
    FacetAlias
    -> Language
    -> ActiveSearch
    -> { a | facets : Facets }
    -> Element SearchMsg
viewFacet alias language activeSearch body =
    case Dict.get alias body.facets of
        Just (ToggleFacetData facet) ->
            let
                toggleFacetConfig : ToggleFacetConfig SearchMsg
                toggleFacetConfig =
                    { language = language
                    , activeSearch = activeSearch
                    , toggleFacet = facet
                    , userClickedFacetToggleMsg = SearchMsg.UserClickedToggleFacet
                    }
            in
            viewToggleFacet toggleFacetConfig

        Just (RangeFacetData facet) ->
            let
                rangeFacetConfig : RangeFacetConfig SearchMsg
                rangeFacetConfig =
                    { language = language
                    , activeSearch = activeSearch
                    , rangeFacet = facet
                    , userEnteredTextMsg = SearchMsg.UserEnteredTextInRangeFacet
                    , userFocusedMsg = SearchMsg.UserFocusedRangeFacet
                    , userLostFocusMsg = SearchMsg.UserLostFocusRangeFacet
                    }
            in
            viewRangeFacet rangeFacetConfig

        Just (SelectFacetData facet) ->
            let
                selectFacetConfig : SelectFacetConfig SearchMsg
                selectFacetConfig =
                    { language = language
                    , activeSearch = activeSearch
                    , selectFacet = facet
                    , numberOfColumns = 3
                    , userClickedFacetExpandMsg = SearchMsg.UserClickedSelectFacetExpand
                    , userChangedFacetBehaviourMsg = SearchMsg.UserChangedFacetBehaviour
                    , userChangedSelectFacetSortMsg = SearchMsg.UserChangedSelectFacetSort
                    , userSelectedFacetItemMsg = SearchMsg.UserClickedSelectFacetItem
                    }
            in
            viewSelectFacet selectFacetConfig

        Just (NotationFacetData facet) ->
            let
                notationFacetConfig : NotationFacetConfig SearchMsg
                notationFacetConfig =
                    { language = language
                    , keyboardFacet = activeSearch.keyboard
                    , userInteractedWithKeyboardMsg = SearchMsg.UserInteractedWithPianoKeyboard
                    , userClickedClearKeyboardQueryMsg = SearchMsg.UserClickedPianoKeyboardSearchClearButton
                    , userClickedPianoKeyboardSearchSubmitMsg = SearchMsg.UserClickedPianoKeyboardSearchSubmitButton
                    }
            in
            viewKeyboardControl notationFacetConfig

        Just (QueryFacetData facet) ->
            let
                queryFacetConfig : QueryFacetConfig SearchMsg
                queryFacetConfig =
                    { language = language
                    , queryFacet = facet
                    , activeSearch = activeSearch
                    , userRemovedMsg = SearchMsg.UserRemovedItemFromQueryFacet
                    , userHitEnterMsg = SearchMsg.UserHitEnterInQueryFacet
                    , userEnteredTextMsg = SearchMsg.UserEnteredTextInQueryFacet
                    , userChangedBehaviourMsg = SearchMsg.UserChangedFacetBehaviour
                    , userChoseOptionMsg = SearchMsg.UserChoseOptionFromQueryFacetSuggest
                    }
            in
            viewQueryFacet queryFacetConfig

        _ ->
            none
