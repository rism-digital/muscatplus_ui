module Page.UI.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignRight, alignTop, column, el, fill, height, mouseOver, none, onLeft, padding, paragraph, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Input exposing (checkbox, labelRight)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.Query exposing (toFacetBehaviours, toNextQuery)
import Page.RecordTypes.Search exposing (FacetBehaviours(..), FacetItem(..), FacetSorts(..), SelectFacet, parseFacetBehaviourToString, parseStringToFacetBehaviour, toBehaviours, toCurrentBehaviour)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (bodySM, linkColour)
import Page.UI.Components exposing (basicCheckbox, dropdownSelect, verticalLine)
import Page.UI.Facets.Shared exposing (facetTitleBar)
import Page.UI.Images exposing (intersectionSvg, sortAlphaDescSvg, sortNumericDescSvg, unionSvg)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Set
import String.Extra as SE
import Url exposing (percentDecode)


type alias SelectFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
    , selectFacet : SelectFacet
    , activeSearch : ActiveSearch msg
    , userClickedFacetExpandMsg : String -> msg
    , userChangedFacetBehaviourMsg : FacetAlias -> FacetBehaviours -> msg
    , userChangedSelectFacetSortMsg : FacetAlias -> FacetSorts -> msg
    , userSelectedFacetItemMsg : FacetAlias -> String -> LanguageMap -> msg
    }


sortFacetItemList : Language -> FacetSorts -> List FacetItem -> List FacetItem
sortFacetItemList language sortBy facetItems =
    case sortBy of
        FacetSortCount ->
            List.sortBy
                (\(FacetItem _ _ count) -> count)
                facetItems
                |> List.reverse

        FacetSortAlpha ->
            List.sortBy
                (\(FacetItem _ langmap _) ->
                    extractLabelFromLanguageMap language langmap
                        |> String.toLower
                )
                facetItems


{-| Show the opposite icon from the current value so that
we can show the user a control to toggle the behaviour
-}
sortIcon : FacetSorts -> Element msg
sortIcon sortType =
    case sortType of
        FacetSortCount ->
            sortAlphaDescSvg colourScheme.black

        FacetSortAlpha ->
            sortNumericDescSvg colourScheme.black


toggledSortType : FacetSorts -> FacetSorts
toggledSortType sortType =
    case sortType of
        FacetSortCount ->
            FacetSortAlpha

        FacetSortAlpha ->
            FacetSortCount


viewSelectFacet :
    SelectFacetConfig msg
    -> Element msg
viewSelectFacet config =
    let
        facetItemList =
            .items config.selectFacet
    in
    if List.length facetItemList == 0 then
        none

    else
        let
            activeSearch =
                config.activeSearch

            serverBehaviourOption =
                toBehaviours config.selectFacet
                    |> toCurrentBehaviour

            currentBehaviourOption =
                toFacetBehaviours activeSearch.nextQuery
                    |> Dict.get facetAlias
                    |> Maybe.withDefault serverBehaviourOption

            isExpanded =
                Set.member facetAlias activeSearch.expandedFacets

            sortedItems =
                sortFacetItemList config.language chosenSort facetItemList

            facetItems =
                if isExpanded then
                    sortedItems

                else
                    List.take 20 sortedItems

            query =
                toNextQuery activeSearch

            facetSorts =
                query.facetSorts

            chosenSort =
                Dict.get facetAlias facetSorts
                    |> Maybe.withDefault (.defaultSort config.selectFacet)

            facetAlias =
                .alias config.selectFacet

            numItems =
                List.length sortedItems

            numColumns =
                if numItems <= 4 then
                    1

                else if numItems <= 8 then
                    2

                else if numItems <= 16 then
                    3

                else
                    4

            numItemsPerGroup =
                (toFloat (List.length facetItems) / toFloat numColumns)
                    |> ceiling

            groupedFacetItems =
                LE.greedyGroupsOf numItemsPerGroup facetItems

            ( behaviourIcon, behaviourText ) =
                case currentBehaviourOption of
                    FacetBehaviourIntersection ->
                        ( intersectionSvg colourScheme.black
                        , extractLabelFromLanguageMap config.language localTranslations.optionsWithAnd
                        )

                    FacetBehaviourUnion ->
                        ( unionSvg colourScheme.black
                        , extractLabelFromLanguageMap config.language localTranslations.optionsWithOr
                        )

            behaviourOptions =
                .behaviours config.selectFacet

            listOfBehavioursForDropdown =
                List.map
                    (\{ label, value } ->
                        ( parseFacetBehaviourToString value, extractLabelFromLanguageMap config.language label )
                    )
                    behaviourOptions.items

            behaviourDropdown =
                row
                    [ height (px 25)
                    , spacing 2
                    , padding 3
                    , Border.rounded 3
                    , Border.width 1
                    , Border.color colourScheme.midGrey
                    , Background.color colourScheme.white
                    , alignRight
                    ]
                    [ el
                        [ width (px 25)
                        , height (px 10)
                        , el tooltipStyle (text behaviourText)
                            |> tooltip onLeft
                        ]
                        behaviourIcon
                    , el
                        [ alignLeft
                        , width (px 60)
                        ]
                        (dropdownSelect
                            { selectedMsg = \inp -> config.userChangedFacetBehaviourMsg facetAlias (parseStringToFacetBehaviour inp)
                            , mouseDownMsg = Nothing
                            , mouseUpMsg = Nothing
                            , choices = listOfBehavioursForDropdown
                            , choiceFn = \inp -> parseStringToFacetBehaviour inp
                            , currentChoice = currentBehaviourOption
                            , selectIdent = facetAlias ++ "-select-behaviour-select"
                            , label = Nothing
                            , language = config.language
                            , inverted = False
                            }
                        )
                    ]

            chosenSortMessage =
                case chosenSort of
                    FacetSortCount ->
                        extractLabelFromLanguageMap config.language localTranslations.sortAlphabetically

                    FacetSortAlpha ->
                        extractLabelFromLanguageMap config.language localTranslations.sortByCount

            sortButton =
                el
                    [ width (px 25)
                    , height (px 25)
                    , onClick (config.userChangedSelectFacetSortMsg facetAlias (toggledSortType chosenSort))
                    , el tooltipStyle (text chosenSortMessage)
                        |> tooltip onLeft
                    , padding 3
                    , Border.rounded 3
                    , Border.width 1
                    , Border.color colourScheme.midGrey
                    , Background.color colourScheme.white
                    , alignRight
                    ]
                    (sortIcon chosenSort)

            showLink =
                if List.length sortedItems > 20 then
                    let
                        showMoreText =
                            if isExpanded then
                                "Collapse values list"

                            else
                                "Expand values list"
                    in
                    el
                        [ onClick (config.userClickedFacetExpandMsg facetAlias)
                        , pointer
                        , alignRight
                        , linkColour
                        ]
                        (text showMoreText)

                else
                    none

            expandCollapseLink =
                el
                    [ alignRight ]
                    showLink

            titleBar =
                facetTitleBar
                    { extraControls =
                        [ behaviourDropdown
                        , sortButton
                        , expandCollapseLink
                        ]
                    , language = config.language
                    , title = .label config.selectFacet
                    , tooltip = config.tooltip
                    }
        in
        row
            [ width fill
            , alignTop
            , alignLeft
            ]
            [ column
                [ width fill
                , alignTop
                , spacing 8
                ]
                [ titleBar
                , row
                    [ width fill
                    , spacing 8
                    ]
                    (List.map (viewSelectFacetItemColumn config) groupedFacetItems
                        |> List.intersperse verticalLine
                    )
                ]
            ]


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

        fullLabel =
            extractLabelFromLanguageMap config.language label

        decodedValue =
            percentDecode value
                |> Maybe.withDefault value

        nextQuery =
            .nextQuery config.activeSearch

        -- percent-decode the value to match it against the value in the
        -- active filter list. If we can't decode it (for some reason) just
        -- return the original value.
        activeFilters =
            nextQuery.filters

        shouldBeChecked =
            Dict.get facetAlias activeFilters
                |> Maybe.withDefault []
                |> List.map (\( val, _ ) -> percentDecode val |> Maybe.withDefault val)
                |> List.member decodedValue
    in
    row
        [ width fill
        , alignLeft
        , padding 2
        , mouseOver [ Background.color colourScheme.lightestBlue ]
        ]
        [ checkbox
            [ Element.htmlAttribute (HA.alt fullLabel)
            , alignLeft
            , alignTop
            , width fill
            ]
            { checked = shouldBeChecked
            , icon = basicCheckbox
            , label =
                labelRight
                    [ bodySM
                    , width fill
                    ]
                    (paragraph
                        [ width fill ]
                        [ text (SE.softEllipsis 50 fullLabel) ]
                    )
            , onChange = \_ -> config.userSelectedFacetItemMsg facetAlias decodedValue label
            }
        , el
            [ alignRight
            , bodySM
            , alignTop
            ]
            (text (formatNumberByLanguage config.language count))
        ]


viewSelectFacetItemColumn : SelectFacetConfig msg -> List FacetItem -> Element msg
viewSelectFacetItemColumn config facetRow =
    column
        [ width (px 250)
        , height fill
        , alignTop
        , spacing 8
        ]
        (List.map (viewSelectFacetItem config) facetRow)
