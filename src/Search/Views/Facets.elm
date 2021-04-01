module Search.Views.Facets exposing (..)

import Element exposing (Element, alignLeft, alignRight, centerX, column, el, fill, none, paddingEach, paddingXY, row, spacingXY, text, width)
import Element.Border as Border
import Element.Input exposing (checkbox, defaultCheckbox, labelLeft, labelRight)
import Html.Attributes as Html
import Search.DataTypes exposing (ApiResponse(..), Facet, FacetItem(..), Model, Msg(..))
import Shared.Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import String.Extra as SE
import UI.Components exposing (h6)
import UI.Style exposing (bodyRegular, pink)


{-|

    Partitions the list of facets into a tuple containing the 'type' facet, and
    the rest of them. This helps us split the facets so that the type can be displayed
    at the top, and the rest on the side.

-}
partitionFacetList : List Facet -> ( List Facet, List Facet )
partitionFacetList facetList =
    List.partition (\f -> f.alias == "type") facetList


viewTypeFacetItems : Facet -> Language -> Element Msg
viewTypeFacetItems typeFacet language =
    row
        [ Border.widthEach { top = 0, left = 0, right = 0, bottom = 1 }
        , Border.color pink
        , paddingXY 0 10
        , centerX
        , width fill
        ]
        (List.map (\t -> viewTypeFacetItem t language) typeFacet.items)


viewTypeFacetItem : FacetItem -> Language -> Element Msg
viewTypeFacetItem fitem language =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label
    in
    column
        [ centerX ]
        [ checkbox
            [ alignLeft
            , spacingXY 20 0
            ]
            { onChange = \t -> NoOp
            , icon = \b -> none
            , checked = False
            , label =
                labelLeft
                    [ bodyRegular
                    , alignLeft
                    ]
                    (text (fullLabel ++ " (" ++ String.fromInt count ++ ")"))
            }
        ]


viewTypeFacet : Model -> Element Msg
viewTypeFacet model =
    let
        language =
            model.language

        templatedResults =
            case model.response of
                Response results ->
                    let
                        typeFacet =
                            partitionFacetList results.facets
                                |> Tuple.first
                                |> List.head

                        typeFacetItems =
                            case typeFacet of
                                Just tf ->
                                    viewTypeFacetItems tf language

                                Nothing ->
                                    none
                    in
                    typeFacetItems

                _ ->
                    none
    in
    templatedResults


viewSidebarFacets : Model -> Element Msg
viewSidebarFacets model =
    let
        language =
            model.language

        currentlySelected =
            model.selectedFacets

        templatedResults =
            case model.response of
                Response results ->
                    let
                        sidebarFacetList =
                            partitionFacetList results.facets
                                |> Tuple.second

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


viewSidebarFacet : List FacetItem -> Facet -> Language -> Element Msg
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


viewSidebarFacetItem : List FacetItem -> String -> FacetItem -> Language -> Element Msg
viewSidebarFacetItem currentlySelected facetfield fitem language =
    let
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        shouldBeChecked =
            List.member fitem currentlySelected
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
