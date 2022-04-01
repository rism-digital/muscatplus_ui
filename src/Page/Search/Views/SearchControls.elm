module Page.Search.Views.SearchControls exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignBottom, alignTop, centerY, column, el, fill, height, htmlAttribute, minimum, none, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.SearchControls.Incipits exposing (viewFacetsForIncipitsMode)
import Page.Search.Views.SearchControls.Institutions exposing (facetsForInstitutionsModeView)
import Page.Search.Views.SearchControls.People exposing (facetsForPeopleModeView)
import Page.Search.Views.SearchControls.Sources exposing (viewFacetsForSourcesMode)
import Page.UI.Attributes exposing (headingSM, lineSpacing, minimalDropShadow)
import Page.UI.ProbeResponse exposing (hasActionableProbeResponse, viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewUpdateMessage : Language -> Bool -> Bool -> Element msg
viewUpdateMessage language applyFilterPrompt hasActionableProbeResponse =
    let
        elMsg =
            if applyFilterPrompt && hasActionableProbeResponse then
                text <| extractLabelFromLanguageMap language localTranslations.applyFiltersToUpdateResults

            else if applyFilterPrompt && not hasActionableProbeResponse then
                text <| extractLabelFromLanguageMap language localTranslations.noResultsWouldBeFound

            else
                none
    in
    el
        [ width fill
        , height (px 30)
        , headingSM
        , Font.bold
        ]
        elMsg


viewSearchButtons : Language -> SearchPageModel -> Element SearchMsg
viewSearchButtons language model =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserEnteredTextInKeywordQueryBox
            , resetMsg = SearchMsg.UserResetAllFilters
            }

        actionableProbeResponse =
            hasActionableProbeResponse model.probeResponse

        disableSubmitButton =
            not <| actionableProbeResponse

        ( submitButtonColours, submitButtonMsg, submitPointerStyle ) =
            if disableSubmitButton then
                ( colourScheme.midGrey |> convertColorToElementColor
                , Nothing
                , htmlAttribute (HA.style "cursor" "not-allowed")
                )

            else
                ( colourScheme.darkBlue |> convertColorToElementColor
                , Just msgs.submitMsg
                , pointer
                )
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
                        [ Border.color submitButtonColours
                        , Background.color submitButtonColours
                        , paddingXY 10 10
                        , height (px 60)
                        , width (shrink |> minimum 120)
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        , submitPointerStyle
                        ]
                        { onPress = submitButtonMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.applyFilters)
                        }
                    ]
                , column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color (colourScheme.turquoise |> convertColorToElementColor)
                        , Background.color (colourScheme.turquoise |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 60)
                        , width (shrink |> minimum 120)
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
                    [ viewUpdateMessage language model.applyFilterPrompt actionableProbeResponse
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
            [ width fill
            , height fill
            , alignTop
            ]
            [ facetLayout
            , viewSearchButtons language model
            ]
        ]
