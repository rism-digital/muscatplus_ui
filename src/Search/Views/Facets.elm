module Search.Views.Facets exposing (..)

import Element exposing (Element, alignLeft, alignRight, centerX, column, el, fill, none, paddingEach, paddingXY, row, spacingXY, text, width)
import Element.Border as Border
import Element.Input exposing (checkbox, defaultCheckbox, labelLeft, labelRight)
import Html.Attributes as Html
import Search.DataTypes exposing (ApiResponse(..), Facet, FacetItem(..), Filter, Model, Msg(..), SearchResponse, convertFacetToFilter)
import Shared.Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import String.Extra as SE
import UI.Components exposing (h6)
import UI.Icons exposing (modeIcons)
import UI.Style exposing (bodyRegular, pink)


viewModeItems : Facet -> Language -> Element Msg
viewModeItems typeFacet language =
    row
        [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 1 }
        , Border.color pink
        , paddingXY 0 10
        , centerX
        , width fill
        ]
        (List.map (\t -> viewModeItem t language) typeFacet.items)


viewModeItem : FacetItem -> Language -> Element Msg
viewModeItem fitem language =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        icon =
            case value of
                "everything" ->
                    modeIcons.everything

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
    in
    row
        [ alignLeft ]
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
        language =
            model.language

        currentlySelected =
            model.selectedFilters

        templatedResults =
            case model.response of
                Response results ->
                    let
                        sidebarFacetList =
                            results.facets

                        sidebarFacets =
                            sidebarFacetList
                                |> List.map (\f -> viewSidebarFacet currentlySelected f language)
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


viewSidebarFacet : List Filter -> Facet -> Language -> Element Msg
viewSidebarFacet currentlySelected facet language =
    let
        -- if the facet item is expanded, then show everything; else show just the first 10.
        facetItems =
            if facet.expanded then
                facet.items

            else
                List.take 10 facet.items
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
