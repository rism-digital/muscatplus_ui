module View exposing (view)

import Browser
import Element exposing (Element, alignRight, centerX, centerY, column, el, fill, fillPortion, height, inFront, layout, link, none, paddingXY, px, row, spacing, text, width)
import Element.Font as Font
import Element.Region as Region
import Language exposing (extractLabelFromLanguageMap, languageOptionsForDisplay, localTranslations, parseLocaleToLanguage)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Model exposing (CurrentRecordViewTab(..), Response(..))
import Page.Response exposing (ServerData(..))
import Page.Route exposing (Route(..))
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize, footerBackground, headerBottomBorder, headingMD, linkColour, minimalDropShadow, pageBackground)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Images exposing (rismLogo)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, footerHeight, headerHeight)
import Page.Views.FrontPage
import Page.Views.InstitutionPage
import Page.Views.NotFoundPage
import Page.Views.PersonPage
import Page.Views.PlacePage
import Page.Views.SearchPage
import Page.Views.SourcePage
import Page.Views.TablesOfContents exposing (createPersonRecordToc, createSourceRecordToc)


view : Model -> Browser.Document Msg
view model =
    let
        page =
            model.page

        pageView =
            case page.route of
                FrontPageRoute ->
                    Page.Views.FrontPage.view

                SearchPageRoute _ ->
                    Page.Views.SearchPage.view

                SourcePageRoute _ ->
                    Page.Views.SourcePage.view

                PersonPageRoute _ ->
                    Page.Views.PersonPage.view

                InstitutionPageRoute _ ->
                    Page.Views.InstitutionPage.view

                PlacePageRoute _ ->
                    Page.Views.PlacePage.view

                --FestivalRoute _ ->
                NotFoundPageRoute ->
                    Page.Views.NotFoundPage.view

                _ ->
                    Page.Views.FrontPage.view

        ( pageTitle, pageToc ) =
            case page.response of
                Response (SearchData _) ->
                    ( extractLabelFromLanguageMap model.language localTranslations.search ++ " RISM"
                    , none
                    )

                Response (SourceData d) ->
                    ( extractLabelFromLanguageMap model.language d.label
                    , createSourceRecordToc d model.language
                    )

                Response (PersonData d) ->
                    let
                        toc =
                            if page.currentTab == DefaultRecordViewTab then
                                createPersonRecordToc d model.language

                            else
                                none
                    in
                    ( extractLabelFromLanguageMap model.language d.label
                    , toc
                    )

                Response (InstitutionData d) ->
                    ( extractLabelFromLanguageMap model.language d.label
                    , none
                    )

                Response (FestivalData d) ->
                    ( extractLabelFromLanguageMap model.language d.label
                    , none
                    )

                Response (RootData _) ->
                    ( "RISM Online"
                    , none
                    )

                _ ->
                    ( "RISM Online"
                    , none
                    )

        wrappedPageView =
            [ layout
                [ width fill
                , bodyFont
                , bodyFontColour
                , fontBaseSize
                , pageBackground
                , inFront pageToc
                ]
                (column
                    [ centerX
                    , width fill
                    , height fill
                    ]
                    [ siteHeader model
                    , pageView model
                    , siteFooter model
                    ]
                )
            ]
    in
    { title = pageTitle
    , body =
        wrappedPageView
    }


siteHeader : Model -> Element Msg
siteHeader model =
    row
        [ width fill
        , height (px headerHeight)
        , headerBottomBorder
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            , paddingXY 20 0
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ column
                    [ width (px 200)
                    , Font.semiBold
                    , headingMD
                    , centerY
                    ]
                    [ link
                        [ Font.color (colourScheme.darkBlue |> convertColorToElementColor) ]
                        { url = "/", label = text "RISM Online" }
                    ]
                , column
                    [ width (fillPortion 8)
                    , centerY
                    ]
                    [ link
                        [ linkColour ]
                        { url = "/", label = text (extractLabelFromLanguageMap model.language localTranslations.home) }
                    ]
                , column
                    [ width (fillPortion 2)
                    , alignRight
                    ]
                    [ row
                        [ alignRight
                        ]
                        [ dropdownSelect UserChangedLanguageSelect languageOptionsForDisplay parseLocaleToLanguage model.language ]
                    ]
                ]
            ]
        ]


siteFooter : Model -> Element Msg
siteFooter model =
    let
        muscatLink =
            if model.showMuscatLinks == True then
                viewMuscatLink model

            else
                none
    in
    row
        [ width fill
        , height (px footerHeight)
        , footerBackground
        , minimalDropShadow
        , Region.footer
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            , paddingXY 20 0
            ]
            [ row
                [ width fill
                , height fill
                , Font.color (colourScheme.white |> convertColorToElementColor)
                , Font.semiBold
                ]
                [ column
                    [ width (px 200) ]
                    [ el
                        []
                        (rismLogo colourScheme.white (footerHeight - 10))
                    ]
                , column
                    [ width (fillPortion 10)
                    ]
                    [ text "Tagline / Impressum" ]
                , muscatLink
                ]
            ]
        ]


viewMuscatLink : Model -> Element Msg
viewMuscatLink model =
    let
        page =
            model.page

        route =
            page.route

        linkBase =
            "https://muscat.rism.info/admin/"

        linkTmpl muscatUrl =
            column
                [ alignRight
                , paddingXY 5 0
                ]
                [ link
                    []
                    { url = muscatUrl
                    , label = text "View record in Muscat"
                    }
                ]

        linkView =
            case route of
                SourcePageRoute id ->
                    linkTmpl (linkBase ++ "sources/" ++ String.fromInt id)

                PersonPageRoute id ->
                    linkTmpl (linkBase ++ "people/" ++ String.fromInt id)

                InstitutionPageRoute id ->
                    linkTmpl (linkBase ++ "institutions/" ++ String.fromInt id)

                _ ->
                    none
    in
    linkView
