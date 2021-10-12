module Page.Views.SearchPage.Facets exposing (..)

import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, html, htmlAttribute, none, paddingEach, paddingXY, pointer, px, row, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input exposing (checkbox, defaultCheckbox, labelLeft, labelRight)
import Html
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import List.Extra as LE
import Msg exposing (Msg(..))
import Page.Converters exposing (convertFacetToFilter)
import Page.Query exposing (FacetBehaviour(..), Filter(..), parseStringToFacetBehaviour)
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetData(..), FacetItem(..), ModeFacet, RangeFacet, SearchBody, SelectFacet, ToggleFacet)
import Page.UI.Attributes exposing (bodyRegular, bodySM, headingSM)
import Page.UI.Components exposing (dropdownSelect, h6)
import Page.UI.Facets.RangeSlider as RangeSlider exposing (RangeSlider)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Images exposing (institutionSvg, intersectionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, sourcesSvg, unionSvg, unknownSvg)
import Page.UI.Keyboard as Keyboard
import Page.UI.Keyboard.Model exposing (Keyboard(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Search exposing (ActiveSearch)
import String.Extra as SE


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

        activeSliders =
            activeSearch.sliders

        activeKeyboard =
            activeSearch.keyboard

        facetBehaviours =
            query.facetBehaviours

        expandedFacets =
            activeSearch.expandedFacets

        facetView =
            case facetConf of
                Just (ToggleFacetData facet) ->
                    viewToggleFacet language activeFilters facet

                Just (RangeFacetData facet) ->
                    viewRangeFacet language activeSliders activeFilters facet

                Just (SelectFacetData facet) ->
                    viewSelectFacet language facetBehaviours activeFilters expandedFacets facet

                Just (NotationFacetData facet) ->
                    viewKeyboardControl language activeKeyboard

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


viewRangeFacet : Language -> Dict String RangeSlider -> List Filter -> RangeFacet -> Element Msg
viewRangeFacet language activeSliders activeFilters body =
    let
        facetAlias =
            body.alias

        toggleSlider =
            case Dict.get facetAlias activeSliders of
                Just slider ->
                    html (Html.map (UserMovedRangeSlider facetAlias) <| RangeSlider.view slider)

                Nothing ->
                    none
    in
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ h6 language body.label ]
            , row
                [ width fill
                , paddingXY 20 10
                ]
                [ el [] toggleSlider ]
            ]
        ]


viewSelectFacet :
    Language
    -> List FacetBehaviour
    -> List Filter
    -> List String
    -> SelectFacet
    -> Element Msg
viewSelectFacet language facetBehaviours activeFilters expandedFacets body =
    let
        facetAlias =
            body.alias

        isExpanded =
            List.member facetAlias expandedFacets

        facetItems =
            if isExpanded == True then
                body.items

            else
                List.take 10 body.items

        -- TODO: Translate!
        showMoreText =
            if isExpanded == True then
                "Show fewer"

            else
                "Show more"

        showLink =
            if List.length body.items > 10 then
                row
                    [ width fill
                    ]
                    [ column
                        [ width fill
                        , bodySM
                        ]
                        [ el
                            [ alignRight
                            , paddingXY 0 5
                            , onClick (UserClickedFacetExpand facetAlias)
                            , pointer
                            ]
                            (text showMoreText)
                        ]
                    ]

            else
                none

        behaviourOptions =
            body.behaviours

        listOfBehavioursForDropdown =
            List.map (\v -> ( v.value, extractLabelFromLanguageMap language v.label )) behaviourOptions.items

        chosenOption =
            LE.find
                (\v ->
                    case v of
                        IntersectionBehaviour f ->
                            f == facetAlias

                        UnionBehaviour f ->
                            f == facetAlias
                )
                facetBehaviours
                |> Maybe.withDefault (IntersectionBehaviour facetAlias)

        behaviourIcon =
            case chosenOption of
                UnionBehaviour _ ->
                    unionSvg colourScheme.slateGrey

                IntersectionBehaviour _ ->
                    intersectionSvg colourScheme.slateGrey

        behaviourDropdown =
            el
                [ alignRight ]
                (dropdownSelect
                    (\inp -> UserChangedFacetBehaviour (parseStringToFacetBehaviour inp facetAlias))
                    listOfBehavioursForDropdown
                    (\inp -> parseStringToFacetBehaviour inp facetAlias)
                    chosenOption
                )
    in
    row
        [ width (px 400)
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ row
                [ width fill
                , paddingEach
                    { top = 0
                    , right = 0
                    , left = 0
                    , bottom = 10
                    }
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ h6 language body.label ]
                , column
                    [ width fill
                    , alignRight
                    , bodySM
                    ]
                    [ row
                        [ width fill
                        , alignRight
                        ]
                        [ behaviourDropdown
                        , el
                            [ width (px 20)
                            , height (px 10)
                            , alignRight
                            ]
                            behaviourIcon
                        ]
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing 5
                    ]
                    (List.map (\fItem -> viewFacetItem language facetAlias activeFilters fItem) facetItems)
                ]
            , row
                [ width fill ]
                []
            , showLink
            ]
        ]


viewFacetItem :
    Language
    -> String
    -> List Filter
    -> FacetItem
    -> Element Msg
viewFacetItem language facetAlias activeFilters fitem =
    let
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        asFilter =
            convertFacetToFilter facetAlias fitem

        shouldBeChecked =
            List.member asFilter activeFilters
    in
    row
        [ width fill ]
        [ checkbox
            [ Element.htmlAttribute (HA.alt fullLabel)
            , alignLeft
            ]
            { onChange = \selected -> UserClickedFacetItem facetAlias fitem selected
            , icon = defaultCheckbox
            , checked = shouldBeChecked
            , label =
                labelRight
                    [ bodyRegular ]
                    (text (SE.softEllipsis 30 fullLabel))
            }
        , el
            [ alignRight
            , bodyRegular
            ]
            (text (formatNumberByLanguage count language))
        ]


viewKeyboardControl : Language -> Keyboard.Model -> Element Msg
viewKeyboardControl language keyboard =
    let
        keyboardConfig =
            { numOctaves = 3 }

        keyboardQuery =
            keyboard.query

        queryLen =
            Maybe.withDefault [] keyboardQuery.noteData
                |> List.length

        cursor =
            if queryLen < 4 then
                "not-allowed"

            else
                "pointer"

        ( buttonMsg, buttonColor, buttonBorder ) =
            if queryLen < 4 then
                ( Nothing
                , colourScheme.darkGrey |> convertColorToElementColor
                , colourScheme.slateGrey |> convertColorToElementColor
                )

            else
                ( Just UserClickedPianoKeyboardSearchSubmitButton
                , colourScheme.darkBlue |> convertColorToElementColor
                , colourScheme.darkBlue |> convertColorToElementColor
                )
    in
    row
        []
        [ column
            []
            [ row []
                [ Keyboard.view language (Keyboard keyboard keyboardConfig)
                    |> Element.map UserInteractedWithPianoKeyboard
                ]
            , row
                []
                [ Input.button
                    [ Border.widthEach { bottom = 1, top = 1, left = 0, right = 1 }
                    , Border.rounded 5
                    , Border.color buttonBorder
                    , Background.color buttonColor
                    , paddingXY 10 10
                    , height (px 50)
                    , width fill
                    , Font.center
                    , Font.color (colourScheme.white |> convertColorToElementColor)
                    , headingSM
                    , htmlAttribute (HA.style "cursor" cursor)
                    ]
                    { onPress = buttonMsg
                    , label = text "Search"
                    }
                ]
            ]
        ]
