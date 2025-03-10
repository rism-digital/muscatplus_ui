module Mobile.Front.Views exposing (view)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingLG, headingMD, lineSpacing, minimalDropShadow)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Facets.KeywordQuery exposing (viewKeywordQueryInput)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (SearchControlsConfig)
import Page.UI.Search.SearchComponents exposing (SearchButtonConfig, hasActionableProbeResponse, queryValidationState, viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


facetFrontMsgConfig : FacetMsgConfig FrontMsg
facetFrontMsgConfig =
    { userClickedToggleMsg = FrontMsg.UserClickedToggleFacet
    , userLostFocusRangeMsg = FrontMsg.UserLostFocusRangeFacet
    , userFocusedRangeMsg = FrontMsg.UserFocusedRangeFacet
    , userEnteredTextRangeMsg = FrontMsg.UserEnteredTextInRangeFacet
    , userClickedFacetExpandSelectMsg = FrontMsg.UserClickedSelectFacetExpand
    , userChangedFacetBehaviourSelectMsg = FrontMsg.UserChangedFacetBehaviour
    , userChangedSelectFacetSortSelectMsg = FrontMsg.UserChangedSelectFacetSort
    , userSelectedFacetItemSelectMsg = FrontMsg.UserClickedSelectFacetItem
    , userInteractedWithPianoKeyboard = FrontMsg.UserInteractedWithPianoKeyboard
    , userRemovedQueryMsg = FrontMsg.UserRemovedItemFromQueryFacet
    , userEnteredTextQueryMsg = FrontMsg.UserEnteredTextInQueryFacet
    , userChangedBehaviourQueryMsg = FrontMsg.UserChangedFacetBehaviour
    , userChoseOptionQueryMsg = FrontMsg.UserChoseOptionFromQueryFacetSuggest
    , nothingHappenedMsg = FrontMsg.NothingHappened
    }


view : Session -> FrontPageModel FrontMsg -> Element FrontMsg
view session model =
    let
        backgroundImage =
            case session.showFrontSearchInterface of
                SourceSearchOption ->
                    Background.image "/static/images/sources.jpg"

                PeopleSearchOption ->
                    Background.image "/static/images/people.jpg"

                InstitutionSearchOption ->
                    Background.image "/static/images/institutions.jpg"

                IncipitSearchOption ->
                    Background.image "/static/images/incipits.jpg"
    in
    row
        [ width fill
        , height fill
        , backgroundImage
        , padding 20
        ]
        [ column
            [ width fill
            , htmlAttribute (HA.style "height" "60vh")
            , Background.color colourScheme.white
            , minimalDropShadow
            ]
            [ frontBodyViewRouter session model ]
        ]


frontBodyViewRouter : Session -> FrontPageModel FrontMsg -> Element FrontMsg
frontBodyViewRouter session model =
    case model.response of
        Loading _ ->
            viewFrontSearchControlsLoading

        Response (FrontData body) ->
            viewFrontSearchControls
                { session = session
                , model = model
                , body = body
                , facetMsgConfig = facetFrontMsgConfig
                , panelToggleMsg = \_ _ -> FrontMsg.NothingHappened
                , userTriggeredSearchSubmitMsg = FrontMsg.UserTriggeredSearchSubmit
                , userEnteredTextInKeywordQueryBoxMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                , userClickedOpenQueryBuilderMsg = FrontMsg.NothingHappened
                }

        _ ->
            el [ Font.size 92 ] (text "Problem")


viewFrontSearchControlsLoading : Element msg
viewFrontSearchControlsLoading =
    row
        [ width fill
        , height fill
        ]
        [ el
            [ width (px 50)
            , height (px 50)
            , centerX
            , centerY
            ]
            (animatedLoader
                [ width (px 50)
                , height (px 50)
                ]
                (spinnerSvg colourScheme.midGrey)
            )
        ]


viewFrontSearchControls : SearchControlsConfig a b FrontMsg -> Element FrontMsg
viewFrontSearchControls cfg =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewFacetPanels cfg
            ]
        ]


viewFacetPanels : SearchControlsConfig a b FrontMsg -> Element FrontMsg
viewFacetPanels cfg =
    let
        language =
            .language cfg.session

        qText =
            toNextQuery (.activeSearch cfg.model)
                |> toKeywordQuery
                |> Maybe.withDefault ""

        queryValidation =
            .probeResponse cfg.model
                |> queryValidationState

        submitMsg =
            if hasActionableProbeResponse (.probeResponse cfg.model) then
                FrontMsg.UserTriggeredSearchSubmit

            else
                FrontMsg.NothingHappened

        ( mainSearchField, secondaryQueryField ) =
            case .showFrontSearchInterface cfg.session of
                IncipitSearchOption ->
                    ( viewFacet
                        { alias = "notation"
                        , language = .language cfg.session
                        , activeSearch = .activeSearch cfg.model
                        , body = cfg.body
                        , tooltip = []
                        , searchPreferences = .searchPreferences cfg.session
                        , suppressKeyboardElementsForMobile = True
                        }
                        cfg.facetMsgConfig
                    , viewKeywordQueryInput
                        { language = language
                        , submitMsg = submitMsg
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        , queryIsValid = queryValidation
                        , userClickedOpenQueryBuilderMsg = FrontMsg.UserClickedOpenQueryBuilder
                        , suppressQueryBuilderButton = True
                        }
                    )

                _ ->
                    ( viewKeywordQueryInput
                        { language = language
                        , submitMsg = submitMsg
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        , queryIsValid = queryValidation
                        , userClickedOpenQueryBuilderMsg = FrontMsg.UserClickedOpenQueryBuilder
                        , suppressQueryBuilderButton = True
                        }
                    , none
                    )
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        , padding 10
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill ]
                [ column
                    [ width fill
                    , alignTop
                    , padding 10
                    , spacing lineSpacing
                    ]
                    [ mainSearchField
                    , secondaryQueryField
                    , viewMobileSearchButtons
                        { language = language
                        , model = cfg.model
                        , isFrontPage = True
                        , submitLabel = localTranslations.showResults
                        , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                        , resetMsg = FrontMsg.UserResetAllFilters
                        , userClickedOpenDownloaderMsg = FrontMsg.NothingHappened
                        , userClickedCloseDownloaderMsg = FrontMsg.NothingHappened
                        }
                    ]
                ]
            ]
        ]


viewMobileSearchButtons :
    SearchButtonConfig model msg
    -> Element msg
viewMobileSearchButtons { language, model, submitLabel, submitMsg, resetMsg } =
    let
        actionableProbeResponse =
            hasActionableProbeResponse model.probeResponse

        ( submitButtonColours, submitButtonMsg, submitPointerStyle ) =
            if model.applyFilterPrompt && actionableProbeResponse then
                ( colourScheme.lightBlue
                , Just submitMsg
                , pointer
                )

            else
                ( colourScheme.midGrey
                , Nothing
                , htmlAttribute (HA.style "cursor" "not-allowed")
                )
    in
    row
        [ alignTop
        , htmlAttribute (HA.style "z-index" "10")
        , width fill
        , centerY
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , spacing 12
                , height (px 50)
                ]
                [ column
                    [ width shrink
                    ]
                    [ Input.button
                        [ Border.color submitButtonColours
                        , Background.color submitButtonColours
                        , height (px 35)
                        , width shrink
                        , Font.center
                        , Font.color colourScheme.white
                        , headingMD
                        , submitPointerStyle
                        , centerY
                        , paddingXY 10 0
                        ]
                        { label = text (extractLabelFromLanguageMap language submitLabel)
                        , onPress = submitButtonMsg
                        }
                    ]
                , column
                    [ width shrink ]
                    [ Input.button
                        [ Border.color colourScheme.turquoise
                        , Background.color colourScheme.turquoise
                        , height (px 35)
                        , width shrink
                        , Font.center
                        , Font.color colourScheme.white
                        , centerY
                        , headingMD
                        , paddingXY 10 0
                        ]
                        { label = text (extractLabelFromLanguageMap language localTranslations.resetAll)
                        , onPress = Just resetMsg
                        }
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ row
                        [ width fill
                        , spacing 5
                        ]
                        [ el
                            [ Font.medium
                            , headingLG
                            ]
                            (viewProbeResponseNumbers language model.probeResponse)
                        ]
                    ]
                ]
            ]
        ]
