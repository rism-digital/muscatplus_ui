module Page.Front.Views exposing (view)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, maximum, minimum, none, paddingXY, paragraph, px, row, scrollbarY, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language.LocalTranslations exposing (localTranslations)
import Page.Error.Views
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.Facets exposing (facetFrontMsgConfig)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.SideBar.Msg exposing (SideBarOption(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (emptyAttribute, headingHero)
import Page.UI.Components exposing (h1)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput, viewFrontKeywordQueryInput)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (SearchControlsConfig)
import Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)
import Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)
import Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)
import Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)
import Page.UI.Search.SearchComponents exposing (hasActionableProbeResponse, viewSearchButtons)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Set


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

                _ ->
                    emptyAttribute
    in
    row
        [ width fill
        , height fill
        , backgroundImage
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , height fill
            , alignLeft
            , alignTop
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
                , checkboxColumns = 4 -- TODO: Make responsive
                , facetMsgConfig = facetFrontMsgConfig
                , panelToggleMsg = FrontMsg.UserClickedFacetPanelToggle
                , userTriggeredSearchSubmitMsg = FrontMsg.UserTriggeredSearchSubmit
                , userEnteredTextInKeywordQueryBoxMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                }

        _ ->
            Page.Error.Views.view session model


viewFrontSearchControls : SearchControlsConfig a b FrontMsg -> Element FrontMsg
viewFrontSearchControls cfg =
    row
        [ width fill
        , height fill
        , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
        , Border.color colourScheme.darkBlue
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height (px 35)
                , Background.color colourScheme.lightGrey
                ]
                []
            , viewSearchButtons
                { language = .language cfg.session
                , model = cfg.model
                , isFrontPage = True
                , submitLabel = localTranslations.showResults
                , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                , resetMsg = FrontMsg.UserResetAllFilters
                }
            , viewFacetPanels cfg
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

                -- Show a blank page if this is ever the choice; it shouldn't be!
                LiturgicalFestivalsOption ->
                    []

        submitMsg =
            if hasActionableProbeResponse (.probeResponse cfg.model) then
                FrontMsg.UserTriggeredSearchSubmit

            else
                FrontMsg.NothingHappened

        qText =
            toNextQuery (.activeSearch cfg.model)
                |> toKeywordQuery
                |> Maybe.withDefault ""

        ( mainSearchField, secondaryQueryField ) =
            case .showFrontSearchInterface cfg.session of
                IncipitSearchOption ->
                    ( viewFacet
                        { activeSearch = .activeSearch cfg.model
                        , alias = "notation"
                        , body = cfg.body
                        , language = .language cfg.session
                        , searchPreferences = .searchPreferences cfg.session
                        , selectColumns = cfg.checkboxColumns
                        , tooltip = []
                        }
                        cfg.facetMsgConfig
                    , searchKeywordInput
                        { language = language
                        , submitMsg = submitMsg
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        }
                    )

                _ ->
                    ( viewFrontKeywordQueryInput
                        { language = language
                        , submitMsg = submitMsg
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
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
            , numberOfSelectColumns = cfg.checkboxColumns
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

                -- Show a blank page if this is ever the choice; it shouldn't be!
                LiturgicalFestivalsOption ->
                    [ none ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    , paddingXY 20 10
                    ]
                    (paragraph
                        [ headingHero
                        , Font.semiBold
                        , paddingXY 0 10
                        ]
                        [ h1 language headingHeroText ]
                        :: mainSearchField
                        :: secondaryQueryField
                        :: facetLayout
                    )
                ]
            ]
        ]


viewFrontSearchControlsLoading : Element FrontMsg
viewFrontSearchControlsLoading =
    row
        [ width fill
        , height fill
        , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
        , Border.color colourScheme.darkBlue
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height (px 95)
                , Background.color colourScheme.lightGrey
                , Border.color colourScheme.darkBlue
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
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
