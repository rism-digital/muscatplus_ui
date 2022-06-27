module Page.UI.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, above, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, mouseOver, none, padding, paddingEach, paragraph, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (checkbox, labelRight)
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import List.Extra as LE
import Page.Query exposing (toFacetBehaviours, toNextQuery)
import Page.RecordTypes.Search exposing (FacetBehaviours(..), FacetItem(..), FacetSorts(..), SelectFacet, parseFacetBehaviourToString, parseStringToFacetBehaviour, toBehaviours, toCurrentBehaviour)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (bodyRegular, bodySM, bodyXS, headingMD, lineSpacing, linkColour)
import Page.UI.Components exposing (basicCheckbox, dropdownSelect, h4, h5)
import Page.UI.Images exposing (intersectionSvg, sortAlphaDescSvg, sortNumericDescSvg, unionSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (facetHelp, tooltip, tooltipStyle)
import Set
import String.Extra as SE


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
            sortAlphaDescSvg colourScheme.slateGrey

        FacetSortAlpha ->
            sortNumericDescSvg colourScheme.slateGrey


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

            -- TODO: Explain this better; why 200 items?
            chosenSort =
                case Dict.get facetAlias facetSorts of
                    Just userSetSort ->
                        userSetSort

                    Nothing ->
                        .defaultSort config.selectFacet

            -- TODO: Translate!
            chosenSortMessage =
                case chosenSort of
                    FacetSortCount ->
                        "Sort alphabetically (currently sorted by count)"

                    FacetSortAlpha ->
                        "Sort by count (currently sorted alphabetically)"

            ( behaviourIcon, behaviourText ) =
                case currentBehaviourOption of
                    FacetBehaviourIntersection ->
                        ( intersectionSvg colourScheme.slateGrey, "Options are combined with an AND operator" )

                    FacetBehaviourUnion ->
                        ( unionSvg colourScheme.slateGrey, "Options are combined with an OR operator" )

            facetAlias =
                .alias config.selectFacet

            -- TODO: Translate!
            facetLabel =
                .label config.selectFacet

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
                        }
                    )
        in
        row
            [ width fill
            , alignTop
            , alignLeft
            , paddingEach { top = 0, bottom = 14, left = 0, right = 0 }
            ]
            [ column
                [ width fill
                , alignTop
                , spacing lineSpacing
                , paddingEach { top = 0, bottom = 0, left = 14, right = 0 }
                , Border.widthEach { top = 0, bottom = 0, left = 2, right = 0 }
                , Border.color (colourScheme.midGrey |> convertColorToElementColor)
                ]
                [ row
                    [ width fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ column
                        [ width shrink
                        , height shrink
                        , centerX
                        , centerY
                        ]
                        [ facetHelp above selectFacetHelp ]
                    , column
                        [ width fill
                        , alignLeft
                        , centerY
                        ]
                        [ row
                            [ spacing 10
                            ]
                            [ el
                                [ headingMD, Region.heading 4, Font.medium ]
                                (text (extractLabelFromLanguageMap config.language facetLabel))
                            , column
                                [ alignLeft ]
                                [ showLink
                                ]
                            ]
                        ]
                    ]
                , row
                    [ width fill
                    , spacing lineSpacing
                    ]
                    (List.map (\fColumn -> viewSelectFacetItemColumn config fColumn) groupedFacetItems)
                , row
                    [ alignLeft
                    , spacing 10
                    , bodyRegular
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
                        , onClick (config.userChangedSelectFacetSortMsg facetAlias (toggledSortType chosenSort))
                        , el tooltipStyle (text chosenSortMessage)
                            |> tooltip above
                        ]
                        (sortIcon chosenSort)
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

        nextQuery =
            .nextQuery config.activeSearch

        activeFilters =
            nextQuery.filters

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
            { checked = shouldBeChecked
            , icon = basicCheckbox
            , label =
                labelRight
                    [ bodyRegular
                    , width fill
                    ]
                    (paragraph [ width fill ] [ text (SE.softEllipsis 50 fullLabel) ])
            , onChange = \_ -> config.userSelectedFacetItemMsg facetAlias value
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
        (List.map (\fitem -> viewSelectFacetItem config fitem) facetRow)
