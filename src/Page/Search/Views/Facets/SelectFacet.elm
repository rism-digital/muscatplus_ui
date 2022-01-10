module Page.Search.Views.Facets.SelectFacet exposing (..)

import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignRight, alignTop, column, el, fill, height, mouseOver, none, padding, paragraph, pointer, px, row, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Input exposing (checkbox, labelRight)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import List.Extra as LE
import Page.RecordTypes.Search exposing (FacetBehaviours(..), FacetItem(..), FacetSorts(..), SelectFacet, parseFacetBehaviourToString, parseStringToFacetBehaviour, toCurrentBehaviour)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (bodyRegular, bodySM, bodyXS, lineSpacing)
import Page.UI.Components exposing (basicCheckbox, dropdownSelect, h5)
import Page.UI.Images exposing (intersectionSvg, sortAlphaDescSvg, sortNumericDescSvg, unionSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import String.Extra as SE


type alias SelectFacetConfig =
    { facetSorts : Dict String FacetSorts
    , activeFilters : Dict FacetAlias (List String)
    , expandedFacets : List String
    }


{-| Show the opposite icon from the current value so that
we can show the user a control to toggle the behaviour
-}
sortIcon : FacetSorts -> Element msg
sortIcon sortType =
    case sortType of
        FacetSortCount ->
            sortAlphaDescSvg colourScheme.slateGrey

        FacetSortAlpha ->
            sortNumericDescSvg colourScheme.slateGrey


toggledSortType : FacetSorts -> FacetSorts
toggledSortType sortType =
    case sortType of
        FacetSortAlpha ->
            FacetSortCount

        FacetSortCount ->
            FacetSortAlpha


sortFacetItemList : Language -> FacetSorts -> List FacetItem -> List FacetItem
sortFacetItemList language sortBy facetItems =
    case sortBy of
        FacetSortAlpha ->
            List.sortBy
                (\i ->
                    let
                        (FacetItem _ langmap _) =
                            i
                    in
                    extractLabelFromLanguageMap language langmap
                )
                facetItems

        FacetSortCount ->
            List.sortBy
                (\i ->
                    let
                        (FacetItem _ _ count) =
                            i
                    in
                    count
                )
                facetItems
                |> List.reverse


viewSelectFacet :
    Language
    -> SelectFacetConfig
    -> SelectFacet
    -> Element SearchMsg
viewSelectFacet language { activeFilters, expandedFacets, facetSorts } body =
    let
        facetAlias =
            body.alias

        serverDefaultSort =
            body.defaultSort

        chosenSort =
            case Dict.get facetAlias facetSorts of
                Just userSetSort ->
                    userSetSort

                Nothing ->
                    serverDefaultSort

        sortedItems =
            sortFacetItemList language chosenSort body.items

        isExpanded =
            List.member facetAlias expandedFacets

        facetItems =
            if isExpanded == True then
                sortedItems

            else
                List.take 12 sortedItems

        numberOfHiddenItems =
            List.length sortedItems - 12

        -- TODO: Explain this better; why 200 items?
        truncatedNote =
            if List.length sortedItems == 200 then
                el
                    [ alignLeft
                    , bodyXS
                    ]
                    (text "Top 200 values shown")

            else
                none

        -- TODO: Translate!
        showMoreText =
            if isExpanded == True then
                "Collapse options list"

            else
                "Show " ++ String.fromInt numberOfHiddenItems ++ " more"

        showLink =
            if List.length sortedItems > 12 then
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

        behaviourOptions =
            body.behaviours

        currentBehaviourOption =
            toCurrentBehaviour behaviourOptions

        listOfBehavioursForDropdown =
            List.map
                (\v ->
                    ( parseFacetBehaviourToString v.value, extractLabelFromLanguageMap language v.label )
                )
                behaviourOptions.items

        behaviourIcon =
            case currentBehaviourOption of
                FacetBehaviourUnion ->
                    unionSvg colourScheme.slateGrey

                FacetBehaviourIntersection ->
                    intersectionSvg colourScheme.slateGrey

        behaviourDropdown =
            el
                [ alignLeft
                , width (px 50)
                ]
                (dropdownSelect
                    (\inp -> UserChangedFacetBehaviour facetAlias (parseStringToFacetBehaviour inp))
                    listOfBehavioursForDropdown
                    (\inp -> parseStringToFacetBehaviour inp)
                    currentBehaviourOption
                )

        groupedFacetItems =
            LE.greedyGroupsOf 3 facetItems
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        , Background.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ row
                [ width fill
                , alignTop
                , padding 10
                , spacing lineSpacing
                ]
                [ column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ row
                        [ spacing 10
                        ]
                        [ h5 language body.label
                        , truncatedNote
                        ]
                    ]
                ]
            , row
                [ width fill
                ]
                [ column
                    [ width fill
                    ]
                    (List.map (\fRow -> viewSelectFacetItemRow language facetAlias activeFilters fRow) groupedFacetItems)
                ]
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
                            , onClick (UserChangedFacetSort facetAlias (toggledSortType chosenSort))
                            ]
                            (sortIcon chosenSort)
                        ]
                    ]
                , showLink
                ]
            ]
        ]


viewSelectFacetItemRow : Language -> String -> Dict FacetAlias (List String) -> List FacetItem -> Element SearchMsg
viewSelectFacetItemRow language facetAlias activeFilters facetRow =
    row
        [ width fill
        , spacingXY (lineSpacing * 2) lineSpacing
        , alignLeft
        ]
        (List.map (\fitem -> viewSelectFacetItem language facetAlias activeFilters fitem) facetRow)


viewSelectFacetItem :
    Language
    -> String
    -> Dict FacetAlias (List String)
    -> FacetItem
    -> Element SearchMsg
viewSelectFacetItem language facetAlias activeFilters fitem =
    let
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        shouldBeChecked =
            Dict.get facetAlias activeFilters
                |> Maybe.withDefault []
                |> List.member value
    in
    column
        [ width (px 220)
        , alignLeft
        , alignTop
        , padding 5
        , mouseOver [ Background.color (colourScheme.lightGrey |> convertColorToElementColor) ]
        ]
        [ row
            [ width fill
            , alignLeft
            ]
            [ checkbox
                [ Element.htmlAttribute (HA.alt fullLabel)
                , alignLeft
                , alignTop
                , width fill
                ]
                { onChange = \selected -> UserClickedFacetItem facetAlias value selected
                , icon = basicCheckbox
                , checked = shouldBeChecked
                , label =
                    labelRight
                        [ bodyRegular
                        , width fill
                        ]
                        (paragraph [ width fill ] [ text (SE.softEllipsis 50 fullLabel) ])
                }
            , el
                [ alignRight
                , bodyRegular
                , alignTop
                ]
                (text (formatNumberByLanguage language count))
            ]
        ]
