module Page.Search.Views.Facets exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, html, htmlAttribute, none, padding, paddingXY, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input exposing (checkbox, defaultCheckbox, labelHidden, labelLeft, labelRight)
import Html
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import List.Extra as LE
import Page.Converters exposing (convertFacetToFilter)
import Page.Query exposing (FacetBehaviour(..), FacetMode(..), FacetSort(..), Filter(..), parseStringToFacetBehaviour)
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetData(..), FacetItem(..), FacetModes(..), FacetSorts(..), ModeFacet, RangeFacet, SearchBody, SelectFacet, ToggleFacet)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (bodyRegular, bodySM, headingMD, headingSM, headingXS)
import Page.UI.Components exposing (dropdownSelect, h5, h6)
import Page.UI.Facets.RangeSlider as RangeSlider exposing (RangeSlider)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Images exposing (checkedBoxSvg, editSvg, institutionSvg, intersectionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, sortAlphaDescSvg, sortNumericDescSvg, sourcesSvg, unionSvg, unknownSvg)
import Page.UI.Keyboard as Keyboard
import Page.UI.Keyboard.Model exposing (Keyboard(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import String.Extra as SE


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
                        [ headingSM
                        , alignLeft
                        ]
                        (text (fullLabel ++ " (" ++ itemCount ++ ")"))
                }
            )
        ]


viewFacet : String -> Language -> ActiveSearch -> SearchBody -> Element SearchMsg
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
    in
    case facetConf of
        Just (ToggleFacetData facet) ->
            viewToggleFacet language activeFilters facet

        Just (RangeFacetData facet) ->
            let
                activeSliders =
                    activeSearch.sliders
            in
            viewRangeFacet language activeSliders activeFilters facet

        Just (SelectFacetData facet) ->
            let
                facetSorts =
                    query.facetSorts

                expandedFacets =
                    activeSearch.expandedFacets

                facetBehaviours =
                    query.facetBehaviours

                facetConfig =
                    { facetBehaviours = facetBehaviours
                    , facetSorts = facetSorts
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

        _ ->
            none


viewToggleFacet : Language -> List Filter -> ToggleFacet -> Element SearchMsg
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


viewRangeFacet : Language -> Dict String RangeSlider -> List Filter -> RangeFacet -> Element SearchMsg
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
                [ h5 language body.label ]
            , row
                [ width fill
                , paddingXY 20 10
                ]
                [ el [] toggleSlider ]
            ]
        ]


type alias SelectFacetConfig =
    { facetBehaviours : List FacetBehaviour
    , facetSorts : Dict String FacetSort
    , activeFilters : List Filter
    , expandedFacets : List String
    }


viewSelectFacet :
    Language
    -> SelectFacetConfig
    -> SelectFacet
    -> Element SearchMsg
viewSelectFacet language { facetBehaviours, activeFilters, expandedFacets, facetSorts } body =
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
                column
                    [ width fill
                    , bodySM
                    ]
                    [ el
                        [ onClick (UserClickedFacetExpand facetAlias)
                        , pointer
                        , alignRight
                        ]
                        (text showMoreText)
                    ]

            else
                none

        -- show the opposite icon from the current value so that
        -- we can show the user a control to toggle the behaviour
        toggledSortIcon sortType =
            case sortType of
                FacetSortCount ->
                    sortAlphaDescSvg colourScheme.slateGrey

                FacetSortAlpha ->
                    sortNumericDescSvg colourScheme.slateGrey

        toggledSortMsg sortType =
            case sortType of
                FacetSortCount ->
                    AlphaSortOrder facetAlias

                FacetSortAlpha ->
                    CountSortOrder facetAlias

        sorts =
            body.sorts

        modes =
            body.modes

        toggledModeIcon modeType =
            case modeType of
                FacetModeCheck ->
                    editSvg colourScheme.slateGrey

                FacetModeText ->
                    checkedBoxSvg colourScheme.slateGrey

        toggledModeMsg modeType =
            case modeType of
                FacetModeCheck ->
                    TextInputSelect facetAlias

                FacetModeText ->
                    CheckboxSelect facetAlias

        facetBodyDisplay modeType =
            case modeType of
                FacetModeCheck ->
                    column
                        [ width fill
                        , spacing 5
                        ]
                        (List.map (\fItem -> viewFacetItem language facetAlias activeFilters fItem) facetItems)

                FacetModeText ->
                    column
                        [ width fill ]
                        [ Input.text
                            []
                            { onChange = \a -> NothingHappened
                            , text = ""
                            , placeholder = Nothing
                            , label = labelHidden ""
                            }
                        ]

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
                [ alignLeft
                , width (px 50)
                ]
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
        , Border.width 1
        , Background.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ row
                [ width fill
                , alignTop
                , Background.color (colourScheme.lightBlue |> convertColorToElementColor)
                , padding 10
                ]
                [ column
                    [ width fill
                    , alignLeft
                    , alignTop
                    , Font.color (colourScheme.white |> convertColorToElementColor)
                    ]
                    [ h6 language body.label ]
                ]
            , row
                [ width fill
                , padding 10
                ]
                [ facetBodyDisplay modes.current ]
            , row
                [ width fill
                , padding 10
                ]
                [ column
                    [ width fill
                    , bodySM
                    , alignLeft
                    ]
                    [ row
                        [ alignLeft
                        , spacing 10
                        ]
                        [ el
                            [ width (px 20)
                            , height (px 10)
                            ]
                            behaviourIcon
                        , behaviourDropdown
                        , el
                            [ width (px 20)
                            , height (px 20)
                            , onClick (UserChangedFacetSort (toggledSortMsg sorts.current))
                            ]
                            (toggledSortIcon sorts.current)
                        , el
                            [ width (px 20)
                            , height (px 20)
                            , onClick (UserChangedFacetMode (toggledModeMsg modes.current))
                            ]
                            (toggledModeIcon modes.current)
                        ]
                    ]
                , showLink
                ]
            ]
        ]


viewFacetItem :
    Language
    -> String
    -> List Filter
    -> FacetItem
    -> Element SearchMsg
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


viewKeyboardControl : Language -> Keyboard.Model -> Element SearchMsg
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
                [ spacing 10 ]
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
                , Input.button
                    [ Border.widthEach { bottom = 1, top = 1, left = 0, right = 1 }
                    , Border.rounded 5
                    , Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                    , Background.color (colourScheme.darkBlue |> convertColorToElementColor)
                    , paddingXY 10 10
                    , height (px 50)
                    , width fill
                    , Font.center
                    , Font.color (colourScheme.white |> convertColorToElementColor)
                    , headingSM
                    , htmlAttribute (HA.style "cursor" "pointer")
                    ]
                    { onPress = Just UserClickedPianoKeyboardSearchClearButton
                    , label = text "Clear"
                    }
                ]
            ]
        ]
