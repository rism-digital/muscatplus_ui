module Mobile.Front.Views exposing (view)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, fillPortion, height, none, padding, px, row, scrollbarY, text, width)
import Element.Background as Background
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.SideBar.Msg exposing (SideBarOption(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (emptyAttribute, minimalDropShadow)
import Page.UI.Facets.KeywordQuery exposing (viewFrontKeywordQueryInput)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Search.SearchComponents exposing (hasActionableProbeResponse)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


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
        , padding 20
        ]
        [ column
            [ width fill
            , padding 10
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
            viewFacetPanels session model

        _ ->
            text "Problem"


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


viewFacetPanels : Session -> FrontPageModel FrontMsg -> Element FrontMsg
viewFacetPanels session model =
    let
        submitMsg =
            if hasActionableProbeResponse (.probeResponse model) then
                FrontMsg.UserTriggeredSearchSubmit

            else
                FrontMsg.NothingHappened
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
            [ viewFrontKeywordQueryInput
                { language = session.language
                , submitMsg = submitMsg
                , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                , queryText = "foo"
                }
            ]
        ]
