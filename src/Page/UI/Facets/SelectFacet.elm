module Page.UI.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, above, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, mouseOver, none, onRight, padding, paragraph, pointer, px, row, shrink, spacing, text, width)
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
import Page.UI.Attributes exposing (bodyRegular, lineSpacing, linkColour)
import Page.UI.Components exposing (basicCheckbox, dropdownSelect, h4)
import Page.UI.Images exposing (intersectionSvg, sortAlphaDescSvg, sortNumericDescSvg, unionSvg)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (facetTooltip, tooltip, tooltipStyle)
import Set
import String.Extra as SE
import Url exposing (percentDecode)


type alias SelectFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
    , selectFacet : SelectFacet
    , activeSearch : ActiveSearch msg
    , numberOfColumns : Int
    , userClickedFacetExpandMsg : String -> msg
    , userChangedFacetBehaviourMsg : FacetAlias -> FacetBehaviours -> msg
    , userChangedSelectFacetSortMsg : FacetAlias -> FacetSorts -> msg
    , userSelectedFacetItemMsg : FacetAlias -> String -> LanguageMap -> msg
    }


selectFacetHelp : String
selectFacetHelp =
    """
    Select from the list of values. You can order the values alphabetically or numerically (the count of the number of
    results) using the sort control below. You can also change the behaviour of how multiple values are combined, selecting
    either "AND" (all values must be present in a document) and "OR" (only one of the values must be present in a document).
    """


sortFacetItemList : Language -> FacetSorts -> List FacetItem -> List FacetItem
sortFacetItemList language sortBy facetItems =
    case sortBy of
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

        FacetSortAlpha ->
            List.sortBy
                (\i ->
                    let
                        (FacetItem _ langmap _) =
                            i
                    in
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
            sortAlphaDescSvg colourScheme.midGrey

        FacetSortAlpha ->
            sortNumericDescSvg colourScheme.midGrey


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
                    List.take 12 sortedItems

            query =
                toNextQuery activeSearch

            facetSorts =
                query.facetSorts

            chosenSort =
                Dict.get facetAlias facetSorts
                    |> Maybe.withDefault (.defaultSort config.selectFacet)

            chosenSortMessage =
                case chosenSort of
                    FacetSortCount ->
                        extractLabelFromLanguageMap config.language localTranslations.sortAlphabetically

                    FacetSortAlpha ->
                        extractLabelFromLanguageMap config.language localTranslations.sortByCount

            ( behaviourIcon, behaviourText ) =
                case currentBehaviourOption of
                    FacetBehaviourIntersection ->
                        ( intersectionSvg colourScheme.midGrey
                        , extractLabelFromLanguageMap config.language localTranslations.optionsWithAnd
                        )

                    FacetBehaviourUnion ->
                        ( unionSvg colourScheme.midGrey
                        , extractLabelFromLanguageMap config.language localTranslations.optionsWithOr
                        )

            facetAlias =
                .alias config.selectFacet

            numItemsPerGroup =
                (toFloat (List.length facetItems) / toFloat config.numberOfColumns)
                    |> ceiling

            groupedFacetItems =
                LE.greedyGroupsOf numItemsPerGroup facetItems

            showLink =
                if List.length sortedItems > 12 then
                    let
                        showMoreText =
                            if isExpanded then
                                "Collapse options list"

                            else
                                let
                                    totalItems =
                                        List.length sortedItems
                                in
                                if totalItems == 200 then
                                    "Show top " ++ String.fromInt totalItems ++ " values"

                                else
                                    "Show all " ++ String.fromInt totalItems ++ " values"
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

            behaviourOptions =
                .behaviours config.selectFacet

            listOfBehavioursForDropdown =
                List.map
                    (\v ->
                        ( parseFacetBehaviourToString v.value, extractLabelFromLanguageMap config.language v.label )
                    )
                    behaviourOptions.items

            behaviourDropdown =
                el
                    [ alignLeft
                    , width (px 50)
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
                    , padding 10
                    , Background.color colourScheme.lightGrey
                    , Border.widthEach { bottom = 0, left = 0, right = 0, top = 2 }
                    , Border.color colourScheme.midGrey
                    ]
                    [ column
                        [ width shrink
                        , height shrink
                        , centerX
                        , centerY
                        ]
                        [ facetTooltip onRight (extractLabelFromLanguageMap config.language config.tooltip) ]
                    , column
                        [ width fill
                        , alignLeft
                        , centerY
                        ]
                        [ row
                            [ spacing 10
                            ]
                            [ h4 config.language (.label config.selectFacet)
                            , column
                                [ alignLeft ]
                                [ row
                                    [ height (px 25)
                                    , spacing 2
                                    , padding 3
                                    , Border.rounded 3
                                    , Border.width 1
                                    , Border.color colourScheme.midGrey
                                    , Background.color colourScheme.white
                                    ]
                                    [ el
                                        [ width (px 25)
                                        , height (px 10)
                                        , el tooltipStyle (text behaviourText)
                                            |> tooltip above
                                        ]
                                        behaviourIcon
                                    , behaviourDropdown
                                    ]
                                ]
                            , column
                                []
                                [ el
                                    [ width (px 25)
                                    , height (px 25)
                                    , onClick (config.userChangedSelectFacetSortMsg facetAlias (toggledSortType chosenSort))
                                    , el tooltipStyle (text chosenSortMessage)
                                        |> tooltip above
                                    , padding 3
                                    , Border.rounded 3
                                    , Border.width 1
                                    , Border.color colourScheme.midGrey
                                    , Background.color colourScheme.white
                                    ]
                                    (sortIcon chosenSort)
                                ]
                            ]
                        ]
                    ]
                , row
                    [ width fill
                    , spacing lineSpacing
                    ]
                    (List.map (viewSelectFacetItemColumn config) groupedFacetItems)
                , row
                    [ alignRight ]
                    [ showLink
                    ]
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
        , padding 5
        , mouseOver [ Background.color colourScheme.lightGrey ]
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
                    [ bodyRegular
                    , width fill
                    ]
                    (paragraph [ width fill ] [ text (SE.softEllipsis 50 fullLabel) ])
            , onChange = \_ -> config.userSelectedFacetItemMsg facetAlias decodedValue label
            }
        , el
            [ alignRight
            , bodyRegular
            , alignTop
            ]
            (text (formatNumberByLanguage config.language count))
        ]


viewSelectFacetItemColumn : SelectFacetConfig msg -> List FacetItem -> Element msg
viewSelectFacetItemColumn config facetRow =
    column
        [ width (px 250)
        , alignTop
        , spacing 4
        ]
        (List.map (viewSelectFacetItem config) facetRow)
