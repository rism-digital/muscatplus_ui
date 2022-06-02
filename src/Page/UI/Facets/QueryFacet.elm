module Page.UI.Facets.QueryFacet exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, above, alignLeft, alignTop, below, centerX, centerY, column, el, fill, height, htmlAttribute, mouseOver, none, padding, paddingXY, pointer, px, row, shrink, spacing, text, width, wrappedRow)
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
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion, toAlias, toSuggestionList)
import Page.UI.Attributes exposing (bodySM, headingSM, lineSpacing)
import Page.UI.Components exposing (dropdownSelect, h5)
import Page.UI.Events exposing (onEnter)
import Page.UI.Images exposing (closeWindowSvg, intersectionSvg, unionSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (facetHelp, tooltip, tooltipStyle)


queryFacetHelp =
    """
    Type your term in the text box, and hit enter. Multiple terms and wildcards are supported.
    Use the controls at the bottom to select between "AND" or "OR" behaviours when combining terms.
    """


type alias QueryFacetConfig msg =
    { language : Language
    , activeSearch : ActiveSearch msg
    , queryFacet : QueryFacet
    , userRemovedMsg : String -> String -> msg
    , userEnteredTextMsg : FacetAlias -> String -> String -> msg
    , userChangedBehaviourMsg : FacetAlias -> FacetBehaviours -> msg
    , userChoseOptionMsg : FacetAlias -> String -> FacetBehaviours -> msg
    }


viewQueryFacet : QueryFacetConfig msg -> Element msg
viewQueryFacet config =
    let
        facetAlias =
            .alias config.queryFacet

        facetLabel =
            .label config.queryFacet

        activeValues : List String
        activeValues =
            toNextQuery config.activeSearch
                |> toFilters
                |> Dict.get facetAlias
                |> Maybe.withDefault []

        textValue =
            .queryFacetValues config.activeSearch
                |> Dict.get facetAlias
                |> Maybe.withDefault ""

        facetBehaviours =
            toBehaviours config.queryFacet
                |> toBehaviourItems

        serverBehaviourOption =
            toBehaviours config.queryFacet
                |> toCurrentBehaviour

        -- if an override hasn't been set in the facetBehaviours
        -- then choose the behaviour that came from the server.
        currentBehaviourOption =
            toNextQuery config.activeSearch
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
                        , Background.color (colourScheme.lightOrange |> convertColorToElementColor)
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , Font.medium
                        , bodySM
                        , Border.width 1
                        ]
                        (row
                            [ spacing 5 ]
                            [ column
                                []
                                [ text t ]
                            , column
                                []
                                [ el
                                    [ width (px 20)
                                    , onClick (config.userRemovedMsg facetAlias t)
                                    ]
                                    (closeWindowSvg colourScheme.white)
                                ]
                            ]
                        )
                )
            <|
                List.reverse activeValues

        -- TODO: Translate
        interspersedOptions =
            case enteredOptions of
                [] ->
                    [ none ]

                _ ->
                    List.intersperse joinWordEl enteredOptions

        listOfBehavioursForDropdown =
            List.map (\v -> ( parseFacetBehaviourToString v.value, extractLabelFromLanguageMap config.language v.label )) facetBehaviours

        ( behaviourIcon, behaviourText ) =
            case currentBehaviourOption of
                FacetBehaviourUnion ->
                    ( unionSvg colourScheme.slateGrey, "Options are combined with an OR operator" )

                FacetBehaviourIntersection ->
                    ( intersectionSvg colourScheme.slateGrey, "Options are combined with an AND operator" )

        suggestionUrl =
            .suggestions config.queryFacet

        activeSuggestion =
            case .activeSuggestion config.activeSearch of
                Just suggestions ->
                    if toAlias suggestions == facetAlias then
                        viewSuggestionDropdown config currentBehaviourOption suggestions

                    else
                        none

                Nothing ->
                    none
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
                    [ width shrink
                    , height shrink
                    , centerX
                    , centerY
                    ]
                    [ facetHelp above queryFacetHelp ]
                , column
                    [ width fill
                    , alignLeft
                    , centerY
                    ]
                    [ row
                        [ spacing 10 ]
                        [ h5 config.language facetLabel ]
                    ]
                ]
            , row
                [ width fill ]
                [ Input.text
                    [ width (px 400)
                    , Border.rounded 0
                    , htmlAttribute (HA.autocomplete False)
                    , onEnter (config.userChoseOptionMsg facetAlias textValue currentBehaviourOption)
                    , headingSM
                    , paddingXY 10 12
                    , below activeSuggestion
                    ]
                    { label = Input.labelHidden (extractLabelFromLanguageMap config.language facetLabel)
                    , placeholder = Just <| Input.placeholder [] (text "Add terms to your query")
                    , text = textValue
                    , onChange = \input -> config.userEnteredTextMsg facetAlias input suggestionUrl
                    }
                ]
            , wrappedRow
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
                , bodySM
                ]
                [ el
                    [ width (px 20)
                    , height (px 10)
                    , el tooltipStyle (text behaviourText)
                        |> tooltip above
                    ]
                    behaviourIcon
                , el
                    [ alignLeft
                    , width (px 50)
                    ]
                    (dropdownSelect
                        { selectedMsg = \inp -> config.userChangedBehaviourMsg facetAlias <| parseStringToFacetBehaviour inp
                        , mouseDownMsg = Nothing
                        , mouseUpMsg = Nothing
                        , choices = listOfBehavioursForDropdown
                        , choiceFn = \inp -> parseStringToFacetBehaviour inp
                        , currentChoice = currentBehaviourOption
                        , selectIdent = facetAlias ++ "-query-behaviour-select"
                        , label = Nothing
                        , language = config.language
                        }
                    )
                ]
            ]
        ]


viewSuggestionDropdown : QueryFacetConfig msg -> FacetBehaviours -> ActiveSuggestion -> Element msg
viewSuggestionDropdown config currentBehaviour activeSuggestions =
    column
        [ width (px 500)
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , spacing 5
        , Border.width 1
        , Border.color (colourScheme.darkGrey |> convertColorToElementColor)
        ]
        (toSuggestionList activeSuggestions
            |> List.map (viewSuggestionItem config currentBehaviour)
        )


viewSuggestionItem : QueryFacetConfig msg -> FacetBehaviours -> LabelValue -> Element msg
viewSuggestionItem config currentBehaviour suggestionItem =
    let
        facetAlias =
            .alias config.queryFacet

        suggestValue =
            extractLabelFromLanguageMap config.language suggestionItem.label
    in
    row
        [ width fill
        , pointer
        , mouseOver
            [ Background.color (colourScheme.lightBlue |> convertColorToElementColor)
            , Font.color (colourScheme.white |> convertColorToElementColor)
            ]
        , padding 10
        , onClick (config.userChoseOptionMsg facetAlias suggestValue currentBehaviour)
        ]
        [ text suggestValue
        ]
