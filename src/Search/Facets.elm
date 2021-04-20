module Search.Facets exposing (..)

import DataTypes exposing (ApiResponse(..), Facet, FacetItem(..), Filter, Model, Msg(..), ResultMode, SearchBody, ServerResponse(..), convertFacetToFilter, parseStringToResultMode)
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fill, height, none, paddingEach, paddingXY, px, row, spacingXY, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (checkbox, defaultCheckbox, labelLeft, labelRight)
import Html.Attributes as Html
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import String.Extra as SE
import UI.Components exposing (h6)
import UI.Icons exposing (modeIcons)
import UI.Style exposing (bodyRegular, bodySM, pink, white)


viewModeItems : ResultMode -> Facet -> Language -> Element Msg
viewModeItems selectedMode typeFacet language =
    row
        [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 1 }
        , Border.color pink
        , centerX
        , width fill
        , height (px 60)
        ]
        (List.map (\t -> viewModeItem selectedMode t language) typeFacet.items)


viewModeItem : ResultMode -> FacetItem -> Language -> Element Msg
viewModeItem selectedMode fitem language =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        icon =
            case value of
                "sources" ->
                    modeIcons.sources

                "people" ->
                    modeIcons.people

                "institutions" ->
                    modeIcons.institutions

                "incipits" ->
                    modeIcons.incipits

                _ ->
                    modeIcons.unknown

        rowMode =
            parseStringToResultMode value

        baseRowStyle =
            [ alignLeft
            , Font.center
            , height fill
            , paddingXY 0 10
            , Border.widthEach { top = 0, left = 0, right = 0, bottom = 3 }
            ]

        rowStyle =
            if selectedMode == rowMode then
                Border.color pink :: baseRowStyle

            else
                Border.color white :: baseRowStyle
    in
    row
        rowStyle
        [ el [ paddingXY 5 0 ] icon
        , el []
            (checkbox
                [ alignLeft
                , spacingXY 20 0
                ]
                { onChange = \t -> ModeChecked "mode" fitem t
                , icon = \b -> none
                , checked = False
                , label =
                    labelLeft
                        [ bodyRegular
                        , alignLeft
                        ]
                        (text fullLabel)
                }
            )
        ]


viewSidebarFacets : Model -> Element Msg
viewSidebarFacets model =
    let
        activeSearch =
            model.activeSearch

        activeQuery =
            activeSearch.query

        language =
            model.language

        currentlySelected =
            activeQuery.filters

        currentlyExpanded =
            activeSearch.expandedFacets

        templatedResults =
            case model.response of
                Response (SearchResponse results) ->
                    let
                        sidebarFacetList =
                            results.facets

                        sidebarFacets =
                            sidebarFacetList
                                |> List.map (\f -> viewSidebarFacet currentlyExpanded currentlySelected f language)
                    in
                    sidebarFacets

                _ ->
                    [ none ]
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            templatedResults
        ]


viewSidebarFacet :
    List String
    -> List Filter
    -> Facet
    -> Language
    -> Element Msg
viewSidebarFacet currentlyExpanded currentlySelected facet language =
    let
        facetIsExpanded =
            List.member facet.alias currentlyExpanded

        facetItems =
            if facetIsExpanded then
                facet.items

            else
                List.take 10 facet.items

        facetShowLink =
            if facetIsExpanded then
                "Show fewer"

            else
                "Show more"

        showLink =
            if List.length facet.items > 10 then
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
                            , onClick (ToggleExpandFacet facet.alias)
                            ]
                            (text facetShowLink)
                        ]
                    ]

            else
                none
    in
    row
        [ width fill
        , paddingEach { top = 0, left = 0, right = 0, bottom = 20 }
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , paddingXY 0 10
                ]
                [ h6 language facet.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\t -> viewSidebarFacetItem currentlySelected facet.alias t language) facetItems)
                ]
            , showLink
            ]
        ]


viewSidebarFacetItem : List Filter -> String -> FacetItem -> Language -> Element Msg
viewSidebarFacetItem currentlySelectedFilters facetfield fitem language =
    let
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        facetConvertedToFilter =
            convertFacetToFilter facetfield fitem

        shouldBeChecked =
            List.member facetConvertedToFilter currentlySelectedFilters
    in
    row
        [ width fill ]
        [ checkbox
            [ Element.htmlAttribute (Html.alt fullLabel)
            , alignLeft
            ]
            { onChange = \selected -> FacetChecked facetfield fitem selected
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
            (text ("(" ++ String.fromInt count ++ ")"))
        ]
