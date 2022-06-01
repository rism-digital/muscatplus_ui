module View exposing (view)

import Browser
import Css
import Css.Global
import Element exposing (Element, alignRight, alignTop, centerX, column, el, fill, height, htmlAttribute, inFront, layout, none, padding, px, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Html.Styled exposing (toUnstyled)
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.About.Views
import Page.Front.Views
import Page.NotFound.Views
import Page.Record.Views.InstitutionPage
import Page.Record.Views.PersonPage
import Page.Record.Views.PlacePage
import Page.Record.Views.SourcePage
import Page.Search.Views
import Page.SideBar.Views
import Page.UI.Animations exposing (progressBar)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize, pageBackground)
import Page.UI.Style exposing (colourScheme, colours, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))


view : Model -> Browser.Document Msg
view model =
    let
        pageSession =
            toSession model

        pageView =
            case model of
                FrontPage session pageModel ->
                    Element.map Msg.UserInteractedWithFrontPage (Page.Front.Views.view session pageModel)

                SearchPage session pageModel ->
                    Element.map Msg.UserInteractedWithSearchPage (Page.Search.Views.view session pageModel)

                SourcePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.SourcePage.view session pageModel)

                PersonPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.PersonPage.view session pageModel)

                InstitutionPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.InstitutionPage.view session pageModel)

                PlacePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.PlacePage.view session pageModel)

                NotFoundPage session pageModel ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Page.NotFound.Views.view session pageModel)

                AboutPage session pageModel ->
                    Element.map Msg.UserInteractedWithAboutPage (Page.About.Views.view session pageModel)

        defaultTitle =
            "RISM Online"

        pageTitle =
            case model of
                SearchPage session _ ->
                    extractLabelFromLanguageMap session.language localTranslations.search ++ " RISM"

                SourcePage session pageModel ->
                    case pageModel.response of
                        Response (SourceData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                PersonPage session pageModel ->
                    case pageModel.response of
                        Response (PersonData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                InstitutionPage session pageModel ->
                    case pageModel.response of
                        Response (InstitutionData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                PlacePage session pageModel ->
                    case pageModel.response of
                        Response (PlaceData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                _ ->
                    defaultTitle

        -- set the colour for links (a tags) globally.
        globalLinkColor =
            let
                { red, green, blue } =
                    colours.lightBlue
            in
            [ Css.color (Css.rgb red green blue) ]

        publicBetaNotice =
            row
                [ width fill
                , height (px 30)
                , Background.color (colourScheme.lightOrange |> convertColorToElementColor)
                , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
                , Border.color (colourScheme.darkOrange |> convertColorToElementColor)
                , padding 8
                ]
                [ el
                    [ centerX
                    , Font.color (colourScheme.white |> convertColorToElementColor)
                    , Font.semiBold
                    ]
                    (text "RISM Online is accessible for testing (Beta Version) and will be officially released in July 2022")
                ]
    in
    { title = pageTitle
    , body =
        [ toUnstyled
            (Css.Global.global
                [ Css.Global.a globalLinkColor
                ]
            )
        , layout
            [ width fill
            , bodyFont
            , bodyFontColour
            , fontBaseSize
            , pageBackground
            ]
            (row
                [ width fill
                , height fill
                ]
                [ column
                    [ width (px 90)
                    , height fill
                    , alignTop
                    , inFront (Element.map Msg.UserInteractedWithSideBar (Page.SideBar.Views.view pageSession))
                    ]
                    []
                , column
                    [ centerX
                    , width fill
                    , height fill
                    ]
                    [ publicBetaNotice
                    , loadingIndicator model
                    , pageView
                    ]
                ]
            )
        ]
    }


loadingIndicator : Model -> Element Msg
loadingIndicator model =
    let
        loadingView =
            row
                [ width fill
                , htmlAttribute (HA.style "z-index" "1")
                ]
                [ progressBar ]

        isLoading resp =
            case resp of
                Loading _ ->
                    True

                _ ->
                    False

        chooseView resp =
            case resp of
                Loading _ ->
                    loadingView

                _ ->
                    none
    in
    case model of
        SearchPage _ pageModel ->
            case pageModel.response of
                Loading _ ->
                    loadingView

                _ ->
                    case pageModel.preview of
                        Loading _ ->
                            loadingView

                        _ ->
                            none

        SourcePage _ pageModel ->
            chooseView pageModel.response

        PersonPage _ pageModel ->
            if List.any (\t -> isLoading t) [ pageModel.response, pageModel.searchResults, pageModel.preview ] then
                loadingView

            else
                none

        InstitutionPage _ pageModel ->
            if List.any (\t -> isLoading t) [ pageModel.response, pageModel.searchResults, pageModel.preview ] then
                loadingView

            else
                none

        FrontPage _ pageModel ->
            chooseView pageModel.response

        _ ->
            none
