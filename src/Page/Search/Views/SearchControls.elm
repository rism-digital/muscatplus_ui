module Page.Search.Views.SearchControls exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignBottom, alignTop, centerY, column, el, fill, height, none, paddingXY, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.Search.Views.SearchControls.Incipits exposing (viewFacetsForIncipitsMode)
import Page.Search.Views.SearchControls.Institutions exposing (facetsForInstitutionsModeView)
import Page.Search.Views.SearchControls.People exposing (facetsForPeopleModeView)
import Page.Search.Views.SearchControls.Sources exposing (viewFacetsForSourcesMode)
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingSM, lineSpacing, minimalDropShadow, widthFillHeightFill)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.ProbeResponse exposing (viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..))


viewUpdateMessage : Language -> Element SearchMsg
viewUpdateMessage language =
    el
        [ width fill
        , height (px 30)
        , headingSM
        , Font.bold
        ]
        (text "Apply filters to update search results")


viewSearchButtons : Language -> SearchPageModel -> Element SearchMsg
viewSearchButtons language model =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserEnteredTextInKeywordQueryBox
            , resetMsg = SearchMsg.UserResetAllFilters
            }
    in
    row
        [ alignBottom
        , Background.color (colourScheme.white |> convertColorToElementColor)

        --, Border.color (colourScheme.lightGrey |> convertColorToElementColor)
        --, Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
        , minimalDropShadow
        , width fill
        , height (px 100)
        , paddingXY 20 0
        , centerY
        ]
        [ column
            [ width fill
            , height fill
            , centerY
            ]
            [ row
                [ width fill
                , height fill
                , spacing lineSpacing
                , centerY
                ]
                [ column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                        , Background.color (colourScheme.darkBlue |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 40)
                        , width shrink
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        ]
                        { onPress = Just msgs.submitMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.applyFilters)
                        }
                    ]
                , column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color (colourScheme.midGrey |> convertColorToElementColor)
                        , Background.color (colourScheme.midGrey |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 40)
                        , width (px 100)
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        ]
                        { onPress = Just msgs.resetMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.resetAll)
                        }
                    ]
                , column
                    [ width fill ]
                    [ viewIf (viewUpdateMessage language) model.applyFilterPrompt
                    , viewProbeResponseNumbers language model.probeResponse
                    ]
                ]
            ]
        ]


viewSearchControls : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewSearchControls language model body =
    let
        currentMode =
            toActiveSearch model
                |> toNextQuery
                |> toMode

        facetLayout =
            case currentMode of
                IncipitsMode ->
                    viewFacetsForIncipitsMode language model body

                SourcesMode ->
                    viewFacetsForSourcesMode language model body

                PeopleMode ->
                    facetsForPeopleModeView language model body

                InstitutionsMode ->
                    facetsForInstitutionsModeView language model body

                LiturgicalFestivalsMode ->
                    none
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            (List.append [ alignTop ] widthFillHeightFill)
            [ facetLayout
            , viewSearchButtons language model
            ]
        ]
