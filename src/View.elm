module View exposing (view)

import Browser
import Css
import Css.Global
import Element exposing (Element, alignTop, centerX, column, fill, height, htmlAttribute, inFront, layout, none, px, row, width)
import Element.Keyed as Keyed
import Html.Attributes as HA
import Html.Styled exposing (toUnstyled)
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.About.Views.About
import Page.About.Views.Help
import Page.About.Views.Options
import Page.Error.Views
import Page.Front.Views
import Page.Record.Views.InstitutionPage
import Page.Record.Views.PersonPage
import Page.Record.Views.PlacePage
import Page.Record.Views.SourcePage
import Page.Search.Views
import Page.SideBar.Views
import Page.UI.Animations exposing (progressBar)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize)
import Page.UI.Style exposing (colourScheme, rgbaFloatToInt)
import Response exposing (Response(..), ServerData(..))


view : Model -> Browser.Document Msg
view model =
    let
        -- set the colour for links (a tags) globally.
        globalLinkColor =
            let
                { blue, green, red } =
                    colourScheme.lightBlue
                        |> rgbaFloatToInt
            in
            [ Css.color (Css.rgb red green blue) ]

        pageSession =
            toSession model

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

        sidebarView =
            if pageSession.isFramed then
                none

            else
                column
                    [ width (px 70)
                    , height fill
                    , alignTop
                    , inFront (Element.map Msg.UserInteractedWithSideBar (Page.SideBar.Views.view pageSession))
                    ]
                    []

        pageView =
            case model of
                NotFoundPage session pageModel ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Page.Error.Views.view session pageModel)

                SearchPage session pageModel ->
                    Element.map Msg.UserInteractedWithSearchPage (Page.Search.Views.view session pageModel)

                FrontPage session pageModel ->
                    Element.map Msg.UserInteractedWithFrontPage (Page.Front.Views.view session pageModel)

                SourcePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.SourcePage.view session pageModel)

                PersonPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.PersonPage.view session pageModel)

                InstitutionPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.InstitutionPage.view session pageModel)

                AboutPage session pageModel ->
                    Element.map Msg.UserInteractedWithAboutPage (Page.About.Views.About.view session pageModel)

                HelpPage session ->
                    Element.map Msg.UserInteractedWithAboutPage (Page.About.Views.Help.view session)

                OptionsPage session pageModel ->
                    Element.map Msg.UserInteractedWithAboutPage (Page.About.Views.Options.view session pageModel)

                PlacePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.PlacePage.view session pageModel)
    in
    { title = pageTitle
    , body =
        [ toUnstyled
            (Css.Global.global
                [ Css.Global.a globalLinkColor -- Ensures in-text links are also displayed in blue.
                ]
            )
        , layout
            [ width fill
            , bodyFont
            , bodyFontColour
            , fontBaseSize

            --, pageBackground
            ]
            (row
                [ width fill
                , height fill
                ]
                [ sidebarView
                , column
                    [ centerX
                    , width fill
                    , height fill
                    ]
                    [ loadingIndicator model
                    , pageView
                    ]
                ]
            )
        ]
    }


loadingIndicator : Model -> Element Msg
loadingIndicator model =
    let
        chooseView resp =
            case resp of
                Loading _ ->
                    loadingView

                _ ->
                    Keyed.el [] ( "progress-bar-none", none )

        isLoading resp =
            case resp of
                Loading _ ->
                    True

                _ ->
                    False

        loadingView =
            row
                [ width fill
                , htmlAttribute (HA.style "z-index" "1")
                ]
                [ progressBar ]
    in
    case model of
        SearchPage _ pageModel ->
            if isLoading pageModel.response || isLoading pageModel.preview then
                loadingView

            else
                Keyed.el [] ( "progress-bar-none", none )

        FrontPage _ pageModel ->
            chooseView pageModel.response

        SourcePage _ pageModel ->
            chooseView pageModel.response

        PersonPage _ pageModel ->
            if List.any (\t -> isLoading t) [ pageModel.response, pageModel.searchResults, pageModel.preview ] then
                loadingView

            else
                Keyed.el [] ( "progress-bar-none", none )

        InstitutionPage _ pageModel ->
            if List.any (\t -> isLoading t) [ pageModel.response, pageModel.searchResults, pageModel.preview ] then
                loadingView

            else
                Keyed.el [] ( "progress-bar-none", none )

        _ ->
            none
