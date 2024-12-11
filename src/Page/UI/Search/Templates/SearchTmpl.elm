module Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl, viewSearchResultsNotFoundTmpl)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, html, htmlAttribute, none, padding, paragraph, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Html as HT
import Html.Attributes as HA
import Language exposing (Language, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractLabelFromLanguageMapWithVariables, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (QueryArgs, buildQueryParameters, setMode)
import Page.RecordTypes.ResultMode exposing (parseStringToResultMode, resultModeHeader)
import Page.RecordTypes.Search exposing (FacetItem(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (h3)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Style exposing (colourScheme)
import Request exposing (serverUrl)


viewResultsListLoadingScreenTmpl : Bool -> Element msg
viewResultsListLoadingScreenTmpl isLoading =
    if isLoading then
        el
            [ width fill
            , height fill
            , Background.color colourScheme.translucentGrey
            , htmlAttribute (HA.attribute "style" "backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px); z-index:200;")
            ]
            (el
                [ width (px 50)
                , height (px 50)
                , centerX
                , centerY
                ]
                (animatedLoader [ width (px 50), height (px 50) ] (spinnerSvg colourScheme.midGrey))
            )

    else
        none


viewSearchResultsErrorTmpl : Language -> String -> Element msg
viewSearchResultsErrorTmpl _ err =
    text err


viewSearchResultsLoadingTmpl : Language -> Element msg
viewSearchResultsLoadingTmpl _ =
    row
        [ width fill
        ]
        [ column
            [ width fill
            , height fill
            , Background.color colourScheme.white
            , scrollbarY
            , htmlAttribute (HA.style "min-height" "unset")
            , alignTop
            ]
            []
        ]


viewSearchResultsNotFoundTmpl :
    { currentQuery : QueryArgs
    , language : Language
    , otherResultsFound : List FacetItem
    }
    -> Element msg
viewSearchResultsNotFoundTmpl { currentQuery, language, otherResultsFound } =
    let
        messageBody =
            if List.isEmpty otherResultsFound then
                viewNoResultsFoundAtAll language currentQuery

            else
                viewSomeResultsFoundOfOtherTypes
                    { currentQuery = currentQuery
                    , language = language
                    , otherResultsFound = otherResultsFound
                    }
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ messageBody ]


viewNoResultsFoundAtAll : Language -> QueryArgs -> Element msg
viewNoResultsFoundAtAll language currentQuery =
    let
        resultType =
            .mode currentQuery
                |> resultModeHeader
                |> extractLabelFromLanguageMap language

        noResultsMessage =
            extractLabelFromLanguageMapWithVariables language
                [ LanguageMapReplacementVariable "recordType" resultType ]
                localTranslations.noResultsHeader
                |> toLanguageMap
    in
    column
        [ width fill
        , alignTop
        , padding 20
        , spacing lineSpacing
        ]
        [ row
            [ width fill ]
            [ h3 language noResultsMessage ]
        , row
            [ width fill ]
            [ paragraph
                [ width fill ]
                [ text (extractLabelFromLanguageMap language localTranslations.noResultsBody) ]
            ]
        ]


viewSomeResultsFoundOfOtherTypes :
    { currentQuery : QueryArgs
    , language : Language
    , otherResultsFound : List FacetItem
    }
    -> Element msg
viewSomeResultsFoundOfOtherTypes { currentQuery, language, otherResultsFound } =
    let
        resultType =
            .mode currentQuery
                |> resultModeHeader
                |> extractLabelFromLanguageMap language

        resultsOfOtherTypesMessage =
            extractLabelFromLanguageMapWithVariables language
                [ LanguageMapReplacementVariable "recordType" resultType ]
                localTranslations.resultsWereFoundForOthers

        listOfOtherSearches =
            row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ row
                        [ width fill ]
                        [ h3 language localTranslations.resultsWereFoundForOthers ]
                    , row
                        [ width fill ]
                        [ paragraph
                            [ width fill ]
                            [ text (resultsOfOtherTypesMessage ++ ": ") ]
                        ]
                    , row
                        [ width fill ]
                        [ column
                            [ width fill ]
                            (List.map
                                (\(FacetItem alias label number) ->
                                    let
                                        newMode =
                                            parseStringToResultMode alias

                                        newQueryLink =
                                            setMode newMode currentQuery
                                                |> buildQueryParameters
                                                |> serverUrl [ "search" ]
                                    in
                                    HT.ul
                                        []
                                        [ HT.li []
                                            [ HT.a
                                                [ HA.href newQueryLink
                                                , HA.style "text-decoration" "none"
                                                ]
                                                [ HT.text (extractLabelFromLanguageMap language label) ]
                                            , HT.span [] [ HT.text (" (" ++ String.fromFloat number ++ ")") ]
                                            ]
                                        ]
                                        |> html
                                )
                                otherResultsFound
                            )
                        ]
                    ]
                ]
    in
    column
        [ width fill
        , alignTop
        , padding 20
        , spacing lineSpacing
        ]
        [ listOfOtherSearches
        ]
