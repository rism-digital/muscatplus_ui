module Mobile.Front.Views exposing (view)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, padding, paddingXY, paragraph, px, row, scrollbarY, text, width)
import Element.Background as Background
import Element.Font as Font
import Html.Attributes as HA
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (headingHero, minimalDropShadow)
import Page.UI.Components exposing (h1)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Facets.KeywordQuery exposing (viewFrontKeywordQueryInput)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (SearchControlsConfig)
import Page.UI.Search.SearchComponents exposing (hasActionableProbeResponse, queryValidationState, viewSearchButtons)
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
                    ]
                    [ paragraph
                        [ headingHero
                        , Font.semiBold
                        , paddingXY 0 10
                        ]
                        [ h1 language headingHeroText ]
                    , viewFrontKeywordQueryInput
                        { language = language
                        , submitMsg = submitMsg
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        , userClickedOpenQueryBuilderMsg = FrontMsg.NothingHappened
                        , queryIsValid = queryValidation
                        }
                    , viewSearchButtons
                        { language = language
                        , model = cfg.model
                        , isFrontPage = True
                        , submitLabel = localTranslations.showResults
                        , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                        , resetMsg = FrontMsg.UserResetAllFilters
                        }
                    ]
                ]
            ]
        ]
