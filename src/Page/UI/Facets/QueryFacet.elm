module Page.UI.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, above, alignLeft, alignTop, below, column, el, fill, height, htmlAttribute, mouseOver, none, onRight, padding, paddingXY, pointer, px, row, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toFacetBehaviours, toFilters, toNextQuery)
import Page.RecordTypes.Search exposing (FacetBehaviours(..), QueryFacet, parseFacetBehaviourToString, parseStringToFacetBehaviour, toBehaviourItems, toBehaviours, toCurrentBehaviour)
import Page.RecordTypes.Shared exposing (FacetAlias, LabelValue)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion, toAlias, toSuggestionList)
import Page.UI.Attributes exposing (bodyRegular, headingSM, lineSpacing)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Events exposing (onEnter)
import Page.UI.Facets.Shared exposing (facetTitleBar)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (closeWindowSvg, intersectionSvg, unionSvg)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (facetHelp, tooltip, tooltipStyle)


type alias QueryFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
    , activeSearch : ActiveSearch msg
    , queryFacet : QueryFacet
    , userRemovedMsg : String -> String -> msg
    , userEnteredTextMsg : FacetAlias -> String -> String -> msg
    , userChangedBehaviourMsg : FacetAlias -> FacetBehaviours -> msg
    , userChoseOptionMsg : FacetAlias -> String -> FacetBehaviours -> msg
    , nothingHappenedMsg : msg
    }


queryFacetHelp : String
queryFacetHelp =
    """
    Type your term in the text box, and hit enter, or select it with your mouse. Multiple
    terms and wildcards are supported. Use the controls to select between "AND" or "OR"
    behaviours when combining terms. The resulting query statement will be shown.
    """


viewQueryFacet : QueryFacetConfig msg -> Element msg
viewQueryFacet config =
    let
        serverBehaviourOption =
            toBehaviours config.queryFacet
                |> toCurrentBehaviour

        currentBehaviourOption =
            toNextQuery config.activeSearch
                |> toFacetBehaviours
                |> Dict.get facetAlias
                |> Maybe.withDefault serverBehaviourOption

        activeSuggestion =
            viewMaybe
                (\suggestions ->
                    viewIf (viewSuggestionDropdown config currentBehaviourOption suggestions) (toAlias suggestions == facetAlias)
                )
                (.activeSuggestion config.activeSearch)

        facetAlias =
            .alias config.queryFacet

        facetLabel =
            .label config.queryFacet

        suggestionUrl =
            .suggestions config.queryFacet

        textValue =
            .queryFacetValues config.activeSearch
                |> Dict.get facetAlias
                |> Maybe.withDefault ""

        -- if an override hasn't been set in the facetBehaviours
        -- then choose the behaviour that came from the server.
        onEnterMsg =
            if String.isEmpty textValue then
                config.nothingHappenedMsg

            else
                config.userChoseOptionMsg facetAlias textValue currentBehaviourOption

        activeValues : List ( String, LanguageMap )
        activeValues =
            toNextQuery config.activeSearch
                |> toFilters
                |> Dict.get facetAlias
                |> Maybe.withDefault []

        -- TODO: Translate
        enteredOptions =
            List.map
                (\( value, label ) ->
                    row
                        [ spacing 5
                        , padding 5
                        , Background.color colourScheme.lightBlue
                        , Font.color colourScheme.white
                        , Font.medium
                        , bodyRegular
                        ]
                        [ column []
                            [ text (extractLabelFromLanguageMap config.language label) ]
                        , column []
                            [ el
                                [ width (px 20)
                                , height (px 20)
                                , pointer
                                , onClick (config.userRemovedMsg facetAlias value)
                                ]
                                (closeWindowSvg colourScheme.white)
                            ]
                        ]
                )
                (List.reverse activeValues)

        queryTermsDisplay =
            List.isEmpty enteredOptions
                |> not
                |> viewIf (queryTermView config.language enteredOptions currentBehaviourOption)

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

        facetBehaviours =
            toBehaviours config.queryFacet
                |> toBehaviourItems

        listOfBehavioursForDropdown =
            List.map (\v -> ( parseFacetBehaviourToString v.value, extractLabelFromLanguageMap config.language v.label )) facetBehaviours

        behaviourControl =
            row
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
                , el
                    [ alignLeft
                    , width (px 60)
                    ]
                    (dropdownSelect
                        { selectedMsg = \inp -> config.userChangedBehaviourMsg facetAlias (parseStringToFacetBehaviour inp)
                        , mouseDownMsg = Nothing
                        , mouseUpMsg = Nothing
                        , choices = listOfBehavioursForDropdown
                        , choiceFn = \inp -> parseStringToFacetBehaviour inp
                        , currentChoice = currentBehaviourOption
                        , selectIdent = facetAlias ++ "-query-behaviour-select"
                        , label = Nothing
                        , language = config.language
                        , inverted = False
                        }
                    )
                ]

        titleBar =
            facetTitleBar
                { extraControls = [ behaviourControl ]
                , language = config.language
                , title = .label config.queryFacet
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
            , spacing lineSpacing
            ]
            [ titleBar
            , row
                [ width fill
                , spacing 10
                ]
                [ Input.text
                    [ width (px 400)
                    , Border.rounded 0
                    , htmlAttribute (HA.autocomplete False)
                    , onEnter onEnterMsg
                    , headingSM
                    , paddingXY 10 12
                    , below activeSuggestion
                    ]
                    { label = Input.labelHidden (extractLabelFromLanguageMap config.language facetLabel)
                    , onChange = \input -> config.userEnteredTextMsg facetAlias input suggestionUrl
                    , placeholder =
                        extractLabelFromLanguageMap config.language localTranslations.addTermsToQuery
                            |> text
                            |> Input.placeholder []
                            |> Just
                    , text = textValue
                    }
                , column
                    [ alignLeft
                    , alignTop
                    ]
                    [ facetHelp onRight queryFacetHelp ]
                ]
            , queryTermsDisplay
            , row
                [ alignLeft
                , spacing 12
                , bodyRegular
                ]
                []
            ]
        ]


viewSuggestionDropdown : QueryFacetConfig msg -> FacetBehaviours -> ActiveSuggestion -> Element msg
viewSuggestionDropdown config currentBehaviour activeSuggestions =
    column
        [ width (px 500)
        , Background.color colourScheme.white
        , spacing 5
        , Border.width 1
        , Border.color colourScheme.darkGrey
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
            [ Background.color colourScheme.lightBlue
            , Font.color colourScheme.white
            ]
        , padding 10
        , onClick (config.userChoseOptionMsg facetAlias suggestValue currentBehaviour)
        ]
        [ text suggestValue
        ]


queryTermView : Language -> List (Element msg) -> FacetBehaviours -> Element msg
queryTermView language enteredOptions currentBehaviourOption =
    let
        interspersedOptions =
            case enteredOptions of
                [] ->
                    [ none ]

                _ ->
                    let
                        joinWordEl =
                            case currentBehaviourOption of
                                FacetBehaviourIntersection ->
                                    el
                                        [ Background.color colourScheme.darkOrange
                                        , Font.color colourScheme.white
                                        , padding 5
                                        , Font.medium
                                        ]
                                        (text "and")

                                FacetBehaviourUnion ->
                                    el
                                        [ Background.color colourScheme.darkOrange
                                        , Font.color colourScheme.white
                                        , padding 5
                                        , Font.medium
                                        ]
                                        (text "or")
                    in
                    List.intersperse joinWordEl enteredOptions
    in
    wrappedRow
        [ width fill
        , spacing lineSpacing
        ]
        (List.append
            [ el
                [ Font.medium
                , padding 5
                ]
                (text (extractLabelFromLanguageMap language localTranslations.queryTerms ++ ":"))
            ]
            interspersedOptions
        )
