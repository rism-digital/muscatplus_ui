module Page.Search.Views.Facets.SelectFacet exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import Element exposing (Element, above, alignLeft, alignRight, alignTop, column, el, fill, height, mouseOver, none, padding, paragraph, pointer, px, row, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Input exposing (checkbox, labelRight)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import List.Extra as LE
import Page.Query exposing (toNextQuery)
import Page.RecordTypes.Search exposing (FacetBehaviours(..), FacetItem(..), FacetSorts(..), SelectFacet, parseFacetBehaviourToString, parseStringToFacetBehaviour, toCurrentBehaviour)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (bodyRegular, bodySM, bodyXS, lineSpacing)
import Page.UI.Components exposing (basicCheckbox, dropdownSelect, h5)
import Page.UI.Images exposing (intersectionSvg, sortAlphaDescSvg, sortNumericDescSvg, unionSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (facetHelp)
import String.Extra as SE


selectFacetHelp =
    """
    Select from the list of values. You can order the values alphabetically or numerically (the count of the number of
    results) using the sort control below. You can also change the behaviour of how multiple values are combined, selecting
    either "AND" (all values must be present in a document) and "OR" (only one of the values must be present in a document).
    """


type alias SelectFacetConfig msg =
    { language : Language
    , selectFacet : SelectFacet
    , activeSearch : ActiveSearch
    , numberOfColumns : Int
    , userClickedFacetExpandMsg : String -> msg
    , userChangedFacetBehaviourMsg : FacetAlias -> FacetBehaviours -> msg
    , userChangedSelectFacetSortMsg : FacetAlias -> FacetSorts -> msg
    , userSelectedFacetItemMsg : FacetAlias -> String -> Bool -> msg
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
    SelectFacetConfig msg
    -> Element msg
viewSelectFacet config =
    let
        facetAlias =
            .alias config.selectFacet

        facetLabel =
            .label config.selectFacet

        serverDefaultSort =
            .defaultSort config.selectFacet

        activeSearch =
            config.activeSearch

        query =
            toNextQuery activeSearch

        facetItemList =
            .items config.selectFacet

        facetSorts =
            query.facetSorts

        chosenSort =
            case Dict.get facetAlias facetSorts of
                Just userSetSort ->
                    userSetSort

                Nothing ->
                    serverDefaultSort

        sortedItems =
            sortFacetItemList config.language chosenSort facetItemList

        isExpanded =
            List.member facetAlias activeSearch.expandedFacets

        facetItems =
            if isExpanded == True then
                sortedItems

            else
                List.take 12 sortedItems

        totalItems =
            List.length sortedItems

        isTruncated =
            totalItems == 200

        -- TODO: Explain this better; why 200 items?
        truncatedNote =
            if isTruncated then
                el
                    [ alignLeft
                    , bodyXS
                    ]
                    (text ("List truncated to " ++ String.fromInt totalItems ++ " values"))

            else
                none

        -- TODO: Translate!
        showMoreText =
            if isExpanded == True then
                "Collapse options list"

            else if isTruncated then
                "Show 200 first values"

            else
                "Show all " ++ String.fromInt totalItems ++ " values"

        showLink =
            if List.length sortedItems > 12 then
                column
                    [ width fill
                    , bodySM
                    ]
                    [ el
                        [ onClick (config.userClickedFacetExpandMsg facetAlias)
                        , pointer
                        , alignRight
                        ]
                        (text showMoreText)
                    ]

            else
                none

        behaviourOptions =
            .behaviours config.selectFacet

        currentBehaviourOption =
            toCurrentBehaviour behaviourOptions

        listOfBehavioursForDropdown =
            List.map
                (\v ->
                    ( parseFacetBehaviourToString v.value, extractLabelFromLanguageMap config.language v.label )
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
                    (\inp -> config.userChangedFacetBehaviourMsg facetAlias <| parseStringToFacetBehaviour inp)
                    listOfBehavioursForDropdown
                    (\inp -> parseStringToFacetBehaviour inp)
                    currentBehaviourOption
                )

        groupedFacetItems =
            LE.greedyGroupsOf config.numberOfColumns facetItems
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ column
                    [ alignTop ]
                    [ facetHelp above selectFacetHelp ]
                , column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ row
                        [ spacing 10
                        ]
                        [ h5 config.language facetLabel
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
                    (List.map (\fRow -> viewSelectFacetItemRow config fRow) groupedFacetItems)
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
                            , onClick (config.userChangedSelectFacetSortMsg facetAlias <| toggledSortType chosenSort)
                            ]
                            (sortIcon chosenSort)
                        ]
                    ]
                , showLink
                ]
            ]
        ]


viewSelectFacetItemRow : SelectFacetConfig msg -> List FacetItem -> Element msg
viewSelectFacetItemRow config facetRow =
    row
        [ width fill
        , spacingXY (lineSpacing * 2) lineSpacing
        , alignLeft
        ]
        (List.map (\fitem -> viewSelectFacetItem config fitem) facetRow)


viewSelectFacetItem :
    SelectFacetConfig msg
    -> FacetItem
    -> Element msg
viewSelectFacetItem config fitem =
    let
        (FacetItem value label count) =
            fitem

        facetAlias =
            .alias config.selectFacet

        nextQuery =
            .nextQuery config.activeSearch

        activeFilters =
            nextQuery.filters

        fullLabel =
            extractLabelFromLanguageMap config.language label

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
                { onChange = \selected -> config.userSelectedFacetItemMsg facetAlias value selected
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
                (text <| formatNumberByLanguage config.language count)
            ]
        ]
