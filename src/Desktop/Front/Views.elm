module Desktop.Front.Views exposing (view)

import Desktop.Error.Views
import Element exposing (Element, alignLeft, alignTop, below, centerX, centerY, column, el, fill, height, htmlAttribute, inFront, none, padding, paragraph, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Region as Region
import Html.Attributes as HA
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.QueryBuilder
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (lineSpacing, minimalDropShadow)
import Page.UI.Components exposing (h1)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Facets.KeywordQuery exposing (viewKeywordQueryInput)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (SearchControlsConfig)
import Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)
import Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)
import Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)
import Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)
import Page.UI.Search.SearchComponents exposing (hasActionableProbeResponse, queryValidationState, viewSearchButtons)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (facetHelp)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Set


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
    , userSelectedFacetItemSingleChoiceMsg = FrontMsg.UserClickedSingleChoiceFacetItem
    , userResetSingleChoiceMsg = FrontMsg.UsersClickedSingleChoiceReset
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

        queryBuilderWindow =
            .activeSearch model
                |> .queryBuilder
                |> viewMaybe
                    (\_ ->
                        Page.QueryBuilder.view
                            { closeMsg = FrontMsg.UserClickedCloseQueryBuilder
                            , language = session.language
                            , model = model
                            , searchResponse = model.response
                            , userInteractedWithQueryBuilderMsg = FrontMsg.UserInteractedWithQueryBuilder
                            }
                    )
    in
    row
        [ width fill
        , height fill
        , alignTop
        , alignLeft
        , backgroundImage
        , htmlAttribute (HA.style "background-position" "top left")
        , inFront queryBuilderWindow
        , Region.mainContent
        ]
        [ column
            [ width (px 1100)
            , height fill
            , Background.color colourScheme.white
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
                , panelToggleMsg = FrontMsg.UserClickedFacetPanelToggle
                , userTriggeredSearchSubmitMsg = FrontMsg.UserTriggeredSearchSubmit
                , userEnteredTextInKeywordQueryBoxMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                , userClickedOpenQueryBuilderMsg = FrontMsg.NothingHappened
                }

        _ ->
            Desktop.Error.Views.view session model


viewFrontSearchControls : SearchControlsConfig a b FrontMsg -> Element FrontMsg
viewFrontSearchControls cfg =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
            , Border.color colourScheme.midGrey
            , height fill
            , alignTop
            ]
            [ viewSearchButtons
                { language = .language cfg.session
                , model = cfg.model
                , isFrontPage = True
                , submitLabel = localTranslations.showResults
                , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                , resetMsg = FrontMsg.UserResetAllFilters
                , userClickedOpenDownloaderMsg = FrontMsg.NothingHappened
                , userClickedCloseDownloaderMsg = FrontMsg.NothingHappened
                }
            , row
                [ width fill
                , height fill
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , height fill
                    ]
                    [ viewFacetPanels cfg ]
                ]
            ]
        ]


viewFrontSearchControlsLoading : Element FrontMsg
viewFrontSearchControlsLoading =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
            ]
            [ row
                [ width fill
                , height (px 85)
                , Background.color colourScheme.lightGrey
                , Border.color colourScheme.midGrey
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , minimalDropShadow
                ]
                []
            , row
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
            ]
        ]


viewFacetPanels : SearchControlsConfig a b FrontMsg -> Element FrontMsg
viewFacetPanels cfg =
    let
        language =
            .language cfg.session

        headingHeroText =
            case .showFrontSearchInterface cfg.session of
                SourceSearchOption ->
                    localTranslations.sources

                PeopleSearchOption ->
                    localTranslations.people

                InstitutionSearchOption ->
                    localTranslations.institutions

                IncipitSearchOption ->
                    localTranslations.incipits

        mainTitle =
            row
                [ width fill
                , alignTop
                , spacing lineSpacing
                , height (px 40)
                ]
                [ column
                    [ centerX
                    , centerY
                    ]
                    [ facetHelp below "Use this to find any words, anywhere in a record." ]
                , column
                    [ width fill
                    , alignLeft
                    , centerY
                    ]
                    [ paragraph
                        [ spacing 10 ]
                        [ h1 language headingHeroText ]
                    ]
                ]

        queryValidation =
            .probeResponse cfg.model
                |> queryValidationState

        suppressBecauseEmpty =
            case .response cfg.model of
                Response (SearchData body) ->
                    List.isEmpty body.queryFields

                Response (FrontData body) ->
                    List.isEmpty body.queryFields

                _ ->
                    True

        submitMsg =
            if hasActionableProbeResponse (.probeResponse cfg.model) then
                FrontMsg.UserTriggeredSearchSubmit

            else
                FrontMsg.NothingHappened

        qText =
            toNextQuery (.activeSearch cfg.model)
                |> toKeywordQuery
                |> Maybe.withDefault ""

        frontSearchInterface =
            .showFrontSearchInterface cfg.session

        ( mainSearchField, secondaryQueryField ) =
            case frontSearchInterface of
                IncipitSearchOption ->
                    ( viewFacet
                        { alias = "notation"
                        , language = .language cfg.session
                        , activeSearch = .activeSearch cfg.model
                        , body = cfg.body
                        , tooltip = []
                        , searchPreferences = .searchPreferences cfg.session
                        , suppressKeyboardElementsForMobile = False
                        }
                        cfg.facetMsgConfig
                    , viewKeywordQueryInput
                        { language = language
                        , submitMsg = submitMsg
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        , queryIsValid = queryValidation
                        , userClickedOpenQueryBuilderMsg = FrontMsg.UserClickedOpenQueryBuilder
                        , suppressQueryBuilderButton = suppressBecauseEmpty
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
                        , suppressQueryBuilderButton = suppressBecauseEmpty
                        }
                    , none
                    )

        expandedFacetPanels =
            case .searchPreferences cfg.session of
                Just p ->
                    p.expandedFacetPanels

                Nothing ->
                    Set.empty

        facetConfig =
            { language = .language cfg.session
            , activeSearch = .activeSearch cfg.model
            , body = cfg.body
            , expandedFacetPanels = expandedFacetPanels
            , panelToggleMsg = cfg.panelToggleMsg
            , facetMsgConfig = cfg.facetMsgConfig
            }

        facetLayout =
            case .showFrontSearchInterface cfg.session of
                SourceSearchOption ->
                    viewFacetsForSourcesMode facetConfig

                PeopleSearchOption ->
                    viewFacetsForPeopleMode facetConfig

                InstitutionSearchOption ->
                    viewFacetsForInstitutionsMode facetConfig

                IncipitSearchOption ->
                    viewFacetsForIncipitsMode facetConfig
    in
    row
        [ width fill
        , height fill
        , padding 20
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            , alignTop
            ]
            [ mainTitle
            , mainSearchField
            , secondaryQueryField
            , row
                [ alignTop
                , width fill
                ]
                [ column
                    [ width fill
                    , height fill
                    ]
                    facetLayout
                ]
            ]
        ]
