module Page.Front.Views exposing (view)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, maximum, minimum, none, padding, paddingEach, paddingXY, paragraph, px, row, scrollbarY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.Facets exposing (facetFrontMsgConfig)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.SideBar.Msg exposing (SideBarOption(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (emptyAttribute, headingHero)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput, viewFrontKeywordQueryInput)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (SearchControlsConfig)
import Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)
import Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)
import Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)
import Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)
import Page.UI.Search.SearchComponents exposing (viewSearchButtons)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
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
        , padding 20
        , backgroundImage
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , height fill
            , alignLeft
            , alignTop
            , Background.color (colourScheme.cream |> convertColorToElementColor)
            , Border.shadow
                { blur = 10
                , color =
                    colourScheme.darkGrey
                        |> convertColorToElementColor
                , offset = ( 1, 1 )
                , size = 1
                }
            ]
            [ frontBodyViewRouter session model ]
        ]


frontBodyViewRouter : Session -> FrontPageModel FrontMsg -> Element FrontMsg
frontBodyViewRouter session model =
    case model.response of
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

        Loading _ ->
            viewFrontSearchControlsLoading

        _ ->
            -- TODO: Implement some sort of error handling here.
            viewFrontSearchControlsError


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
            [ viewSearchButtons
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

        qText =
            toNextQuery (.activeSearch cfg.model)
                |> toKeywordQuery
                |> Maybe.withDefault ""

        headingHeroText =
            case .showFrontSearchInterface cfg.session of
                SourceSearchOption ->
                    extractLabelFromLanguageMap language localTranslations.sources

                PeopleSearchOption ->
                    extractLabelFromLanguageMap language localTranslations.people

                InstitutionSearchOption ->
                    extractLabelFromLanguageMap language localTranslations.institutions

                IncipitSearchOption ->
                    extractLabelFromLanguageMap language localTranslations.incipits

                -- Show a blank page if this is ever the choice; it shouldn't be!
                LiturgicalFestivalsOption ->
                    ""

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

        ( mainSearchField, secondaryQueryField ) =
            case .showFrontSearchInterface cfg.session of
                IncipitSearchOption ->
                    ( viewFacet
                        { alias = "notation"
                        , language = .language cfg.session
                        , activeSearch = .activeSearch cfg.model
                        , selectColumns = cfg.checkboxColumns
                        , body = cfg.body
                        }
                        cfg.facetMsgConfig
                    , searchKeywordInput
                        { language = language
                        , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        }
                    )

                _ ->
                    ( viewFrontKeywordQueryInput
                        { language = language
                        , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        }
                    , none
                    )

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
            , paddingXY 20 10
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    (paragraph
                        [ headingHero
                        , Font.semiBold
                        , padding 10
                        ]
                        [ text headingHeroText ]
                        :: mainSearchField
                        :: row
                            [ width fill
                            , paddingEach { top = 10, bottom = 0, left = 0, right = 0 }
                            ]
                            -- TODO: Translate
                            [ dividerWithText "Additional filters"
                            ]
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
        ]
        [ el
            [ width (px 50)
            , height (px 50)
            , centerX
            , centerY
            ]
            (animatedLoader [ width (px 50), height (px 50) ] (spinnerSvg colourScheme.slateGrey))
        ]


viewFrontSearchControlsError : Element FrontMsg
viewFrontSearchControlsError =
    row
        [ width fill
        , height fill
        ]
        [ text "nothing to see here." ]



--view : Session -> FrontPageModel FrontMsg -> Element FrontMsg
--view session model =
--    let
--        -- returns a partially-applied function that can be used in the viewMaybe
--        -- for the body argument
--        backgroundImage =
--            case session.showFrontSearchInterface of
--                SourceSearchOption ->
--                    Background.image "/static/images/sources.jpg"
--
--                PeopleSearchOption ->
--                    Background.image "/static/images/people.jpg"
--
--                InstitutionSearchOption ->
--                    Background.image "/static/images/institutions.jpg"
--
--                IncipitSearchOption ->
--                    Background.image "/static/images/incipits.jpg"
--
--                _ ->
--                    emptyAttribute
--
--        searchButtonsControls =
--            viewMaybe
--                (\_ ->
--
--                )
--                maybeBody
--
--        -- viewMaybe will be either the searchViewFn, or the `none`
--        -- element if the maybeBody parameter is Nothing.
--        searchViewFn =
--            case session.showFrontSearchInterface of
--                SourceSearchOption ->
--                    sourceSearchPanelView session model
--
--                PeopleSearchOption ->
--                    peopleSearchPanelView session model
--
--                InstitutionSearchOption ->
--                    institutionSearchPanelView session model
--
--                IncipitSearchOption ->
--                    incipitSearchPanelView session model
--
--                -- Show a blank page if this is ever the choice; it shouldn't be!
--                LiturgicalFestivalsOption ->
--                    \_ -> none
--
--        searchPanelView =
--            viewMaybe searchViewFn maybeBody
--    in
--    row
--        [ width fill
--        , height fill
--        , padding 20
--        , backgroundImage
--        ]
--        [ column
--            [ width (fill |> minimum 800 |> maximum 1100)
--            , height fill
--            , alignLeft
--            , alignTop
--            , Background.color (colourScheme.cream |> convertColorToElementColor)
--            , Border.shadow
--                { blur = 10
--                , color =
--                    colourScheme.darkGrey
--                        |> convertColorToElementColor
--                , offset = ( 1, 1 )
--                , size = 1
--                }
--            ]
--            [ searchButtonsControls
--            , viewFrontSearchControls
--                { language = session.language
--                , model = model
--                , body = }
--            ]
--        ]
--
--viewFrontBodyRouter : Session -> FrontPageModel FrontMsg -> Element FrontMsg
--viewFrontBodyRouter session model =
--    let
--        foo = "bar"
--    in
--    case model.response of
--        Response (FrontData body) ->
--            viewFrontSearchControls
--                {}
--
--        _ ->
--            -- TODO: Implement some sort of error handling here.
--            Nothing
--
--
--
--viewFrontSearchControls : SearchControlsConfig a b FrontMsg -> Element FrontMsg
--viewFrontSearchControls cfg =
--    let
--        qText = ""
--        facetLayout =
--            case
--    in
--    row
--            [ width fill
--            , height fill
--            , alignTop
--            , scrollbarY
--            ]
--            [ column
--                [ width fill
--                , alignTop
--                , paddingXY 20 10
--                ]
--                [ row
--                    [ width fill
--                    , alignTop
--                    ]
--                    [ column
--                        [ width fill
--                        , alignTop
--                        ]
--                        (paragraph
--                            [ headingHero
--                            , Font.semiBold
--                            , padding 10
--                            ]
--                            [ text (extractLabelFromLanguageMap cfg.language localTranslations.sources) ]
--                            :: viewFrontKeywordQueryInput
--                                { language = cfg.language
--                                , submitMsg = FrontMsg.UserTriggeredSearchSubmit
--                                , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
--                                , queryText = qText
--                                }
--                            :: row
--                                [ width fill
--                                , paddingEach { top = 10, bottom = 0, left = 0, right = 0 }
--                                ]
--                                -- TODO: Translate
--                                [ dividerWithText "Additional filters"
--                                ]
--                            :: facetLayout
--                        )
--                    ]
--                ]
--            ]
