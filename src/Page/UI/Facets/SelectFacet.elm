module Page.UI.Facets.SelectFacet exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
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
import Page.UI.Attributes exposing (bodyRegular, bodySM, bodyXS, lineSpacing)
import Page.UI.Components exposing (basicCheckbox, dropdownSelect, h5)
import Page.UI.Images exposing (intersectionSvg, sortAlphaDescSvg, sortNumericDescSvg, unionSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (facetHelp, tooltip, tooltipStyle)
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
    , activeSearch : ActiveSearch msg
    , numberOfColumns : Int
    , userClickedFacetExpandMsg : String -> msg
    , userChangedFacetBehaviourMsg : FacetAlias -> FacetBehaviours -> msg
    , userChangedSelectFacetSortMsg : FacetAlias -> FacetSorts -> msg
    , userSelectedFacetItemMsg : FacetAlias -> String -> msg
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

        -- TODO: Translate!
        chosenSortMessage =
            case chosenSort of
                FacetSortCount ->
                    "Sort alphabetically (currently sorted by count)"

                FacetSortAlpha ->
                    "Sort by count (currently sorted alphabetically)"

        sortedItems =
            sortFacetItemList config.language chosenSort facetItemList

        isExpanded =
            List.member facetAlias activeSearch.expandedFacets

        facetItems =
            if isExpanded then
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
            if isExpanded then
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

        ( behaviourIcon, behaviourText ) =
            case currentBehaviourOption of
                FacetBehaviourUnion ->
                    ( unionSvg colourScheme.slateGrey, "Options are combined with an OR operator" )

                FacetBehaviourIntersection ->
                    ( intersectionSvg colourScheme.slateGrey, "Options are combined with an AND operator" )

        behaviourDropdown =
            el
                [ alignLeft
                , width (px 50)
                ]
                (dropdownSelect
                    { selectedMsg = \inp -> config.userChangedFacetBehaviourMsg facetAlias <| parseStringToFacetBehaviour inp
                    , mouseDownMsg = Nothing
                    , mouseUpMsg = Nothing
                    , choices = listOfBehavioursForDropdown
                    , choiceFn = \inp -> parseStringToFacetBehaviour inp
                    , currentChoice = currentBehaviourOption
                    , selectIdent = facetAlias ++ "-select-behaviour-select"
                    , label = Nothing
                    , language = config.language
                    }
                )

        numGroups =
            ceiling <| toFloat (List.length facetItems) / toFloat config.numberOfColumns

        groupedFacetItems =
            LE.greedyGroupsOf numGroups facetItems
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
                , spacing lineSpacing
                ]
                (List.map (\fColumn -> viewSelectFacetItemColumn config fColumn) groupedFacetItems)
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
                            , el tooltipStyle (text behaviourText)
                                |> tooltip above
                            ]
                            behaviourIcon
                        , behaviourDropdown
                        , el
                            [ width (px 20)
                            , height (px 20)
                            , onClick (config.userChangedSelectFacetSortMsg facetAlias <| toggledSortType chosenSort)
                            , el tooltipStyle (text chosenSortMessage)
                                |> tooltip above
                            ]
                            (sortIcon chosenSort)
                        ]
                    ]
                , showLink
                ]
            ]
        ]


viewSelectFacetItemColumn : SelectFacetConfig msg -> List FacetItem -> Element msg
viewSelectFacetItemColumn config facetRow =
    column
        [ width (px 250)
        , alignTop
        , spacing 4
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
    row
        [ width fill
        , alignLeft
        , padding 5
        , mouseOver [ Background.color (colourScheme.lightGrey |> convertColorToElementColor) ]
        ]
        [ checkbox
            [ Element.htmlAttribute (HA.alt fullLabel)
            , alignLeft
            , alignTop
            , width fill
            ]
            { onChange = \_ -> config.userSelectedFacetItemMsg facetAlias value
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
