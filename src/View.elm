module View exposing (view)

import Browser
import Css
import Css.Global
import Element exposing (Element, alignTop, centerX, column, fill, height, inFront, layout, none, px, row, width)
import Html.Styled exposing (toUnstyled)
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Model exposing (Model(..), toSession)
import Msg exposing (Msg(..))
import Page.Front.Views
import Page.NotFound.Views
import Page.Record.Model exposing (CurrentRecordViewTab(..))
import Page.Record.Views.InstitutionPage
import Page.Record.Views.PersonPage
import Page.Record.Views.PersonPage.TableOfContents exposing (createPersonRecordToc)
import Page.Record.Views.PlacePage
import Page.Record.Views.SourcePage
import Page.Record.Views.SourcePage.TableOfContents exposing (createSourceRecordToc)
import Page.Search.Views
import Page.SideBar.Views
import Page.UI.Animations exposing (progressBar)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize, pageBackground)
import Page.UI.Style exposing (colours)
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

        defaultView =
            ( "RISM Online", none )

        ( pageTitle, _ ) =
            case model of
                SearchPage session _ ->
                    ( extractLabelFromLanguageMap session.language localTranslations.search ++ " RISM"
                    , none
                    )

                SourcePage session pageModel ->
                    case pageModel.response of
                        Response (SourceData body) ->
                            ( extractLabelFromLanguageMap session.language body.label
                            , Element.map UserInteractedWithRecordPage (createSourceRecordToc session.language body)
                            )

                        _ ->
                            defaultView

                PersonPage session pageModel ->
                    case pageModel.response of
                        Response (PersonData body) ->
                            ( extractLabelFromLanguageMap session.language body.label
                            , none
                            )

                        _ ->
                            defaultView

                InstitutionPage session pageModel ->
                    case pageModel.response of
                        Response (InstitutionData body) ->
                            ( extractLabelFromLanguageMap session.language body.label
                            , none
                            )

                        _ ->
                            defaultView

                PlacePage session pageModel ->
                    case pageModel.response of
                        Response (PlaceData body) ->
                            ( extractLabelFromLanguageMap session.language body.label
                            , none
                            )

                        _ ->
                            defaultView

                _ ->
                    defaultView

        -- set the colour for links (a tags) globally.
        globalLinkColor =
            let
                { red, green, blue } =
                    colours.lightBlue
            in
            [ Css.color (Css.rgb red green blue) ]
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
        loadingView =
            row
                [ width fill
                ]
                [ progressBar ]

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
            chooseView pageModel.response

        InstitutionPage _ pageModel ->
            chooseView pageModel.response

        FrontPage _ pageModel ->
            chooseView pageModel.response

        _ ->
            none
