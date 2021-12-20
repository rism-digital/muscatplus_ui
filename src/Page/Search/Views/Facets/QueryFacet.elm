module Page.Search.Views.Facets.QueryFacet exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignTop, below, column, el, fill, height, htmlAttribute, mouseOver, none, padding, paddingXY, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Query exposing (toFacetBehaviours, toFilters, toNextQuery)
import Page.RecordTypes.Search exposing (FacetBehaviours(..), QueryFacet, parseFacetBehaviourToString, parseStringToFacetBehaviour, toBehaviourItems, toBehaviours, toCurrentBehaviour)
import Page.RecordTypes.Shared exposing (FacetAlias, LabelValue)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion(..), toAlias, toSuggestionList)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (headingSM, lineSpacing)
import Page.UI.Components exposing (dropdownSelect, h6)
import Page.UI.Events exposing (onEnter)
import Page.UI.Images exposing (intersectionSvg, unionSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewQueryFacet : Language -> QueryFacet -> ActiveSearch -> Element SearchMsg
viewQueryFacet language facet activeSearch =
    let
        facetAlias =
            facet.alias

        currentValues =
            toNextQuery activeSearch
                |> toFilters
                |> Dict.get facetAlias

        textValue =
            currentValues
                |> Maybe.andThen List.head
                |> Maybe.withDefault ""

        activeValues =
            currentValues
                |> Maybe.andThen List.tail
                |> Maybe.withDefault []

        facetBehaviours =
            toBehaviours facet
                |> toBehaviourItems

        serverBehaviourOption =
            toBehaviours facet
                |> toCurrentBehaviour

        -- if an override hasn't been set in the facetBehaviours
        -- then choose the behaviour that came from the server.
        currentBehaviourOption =
            toNextQuery activeSearch
                |> toFacetBehaviours
                |> Dict.get facetAlias
                |> Maybe.withDefault serverBehaviourOption

        joinWordEl =
            case currentBehaviourOption of
                FacetBehaviourIntersection ->
                    el [] (text "<and>")

                FacetBehaviourUnion ->
                    el [] (text "<or>")

        enteredOptions =
            List.map
                (\t ->
                    el
                        [ padding 5
                        , Border.color (colourScheme.lightOrange |> convertColorToElementColor)
                        , Border.width 1
                        ]
                        (text t)
                )
                (List.reverse activeValues)

        -- TODO: Translate
        interspersedOptions =
            case enteredOptions of
                [] ->
                    [ el [ Font.italic ] (text "Add a term to your query above, and hit enter. Multiple terms and wildcards are supported.") ]

                _ ->
                    List.intersperse joinWordEl enteredOptions

        listOfBehavioursForDropdown =
            List.map (\v -> ( parseFacetBehaviourToString v.value, extractLabelFromLanguageMap language v.label )) facetBehaviours

        behaviourIcon =
            case currentBehaviourOption of
                FacetBehaviourUnion ->
                    unionSvg colourScheme.slateGrey

                FacetBehaviourIntersection ->
                    intersectionSvg colourScheme.slateGrey

        suggestionUrl =
            facet.suggestions

        activeSuggestion =
            case activeSearch.activeSuggestion of
                Just suggestions ->
                    if toAlias suggestions == facetAlias then
                        viewSuggestionDropdown language facetAlias currentBehaviourOption suggestions

                    else
                        none

                Nothing ->
                    none
    in
    row
        [ width fill
        , alignTop
        , padding 10
        , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
        , Border.color (colourScheme.lightGrey |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ h6 language facet.label ]
            , row
                [ width fill ]
                [ Input.text
                    [ width (px 400)
                    , Border.rounded 0
                    , htmlAttribute (HA.autocomplete False)
                    , onEnter (UserHitEnterInQueryFacet facet.alias currentBehaviourOption)
                    , headingSM
                    , paddingXY 10 12
                    , below activeSuggestion
                    ]
                    { label = Input.labelHidden (extractLabelFromLanguageMap language facet.label)
                    , placeholder = Just (Input.placeholder [] (text "Add terms to your query"))
                    , text = textValue
                    , onChange = \input -> UserEnteredTextInQueryFacet facet.alias input suggestionUrl
                    }
                ]
            , row
                [ width fill
                , spacing lineSpacing
                ]
                (List.append
                    [ el
                        [ Font.medium
                        , padding 5
                        ]
                        (text "Query:")
                    ]
                    interspersedOptions
                )
            , row
                [ alignLeft
                , spacing 10
                ]
                [ el
                    [ width (px 20)
                    , height (px 10)
                    ]
                    behaviourIcon
                , el
                    [ alignLeft
                    , width (px 50)
                    ]
                    (dropdownSelect
                        (\inp -> UserChangedFacetBehaviour facetAlias (parseStringToFacetBehaviour inp))
                        listOfBehavioursForDropdown
                        (\inp -> parseStringToFacetBehaviour inp)
                        currentBehaviourOption
                    )
                ]
            ]
        ]


viewSuggestionDropdown : Language -> FacetAlias -> FacetBehaviours -> ActiveSuggestion -> Element SearchMsg
viewSuggestionDropdown language facetAlias currentBehaviour activeSuggestions =
    column
        [ width (px 500)
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , spacing 5
        , Border.width 1
        , Border.color (colourScheme.darkGrey |> convertColorToElementColor)
        ]
        (toSuggestionList activeSuggestions
            |> List.map (viewSuggestionItem language facetAlias currentBehaviour)
        )


viewSuggestionItem : Language -> FacetAlias -> FacetBehaviours -> LabelValue -> Element SearchMsg
viewSuggestionItem language facetAlias currentBehaviour suggestionItem =
    let
        suggestValue =
            extractLabelFromLanguageMap language suggestionItem.label
    in
    row
        [ width fill
        , pointer
        , mouseOver
            [ Background.color (colourScheme.lightBlue |> convertColorToElementColor)
            , Font.color (colourScheme.white |> convertColorToElementColor)
            ]
        , padding 10
        , onClick (UserChoseOptionFromQueryFacetSuggest facetAlias suggestValue currentBehaviour)
        ]
        [ text suggestValue
        ]
