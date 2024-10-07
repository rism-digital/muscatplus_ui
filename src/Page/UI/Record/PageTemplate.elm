module Page.UI.Record.PageTemplate exposing
    ( mobilePageHeaderTemplate
    , mobileSubHeaderTemplate
    , pageFooterTemplateRouter
    , pageFullMobileRecordTemplate
    , pageFullRecordTemplate
    , pageHeaderTemplate
    , pageHeaderTemplateNoToc
    , subHeaderTemplate
    )

import Config as C
import Element exposing (Attribute, Element, alignBottom, alignLeft, alignRight, centerY, column, el, fill, htmlAttribute, newTabLink, none, padding, row, shrink, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.Route exposing (Route(..))
import Page.UI.Attributes exposing (headingLG, headingMD, lineSpacing, linkColour, minimalDropShadow)
import Page.UI.Components exposing (externalLinkTemplate, h1, h2s, h3s, resourceLink)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (rismLogo)
import Page.UI.Record.RecordHistory exposing (viewRecordHistory)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)
import Url


pageFooterTemplateRouter : Session -> Language -> { a | id : String, recordHistory : RecordHistory } -> Element msg
pageFooterTemplateRouter session language footer =
    if session.isFramed then
        pageFooterTemplateFramed session language footer

    else
        pageFooterTemplate session language footer


pageFooterTemplateFramed : Session -> Language -> { a | id : String, recordHistory : RecordHistory } -> Element msg
pageFooterTemplateFramed _ _ footer =
    row
        [ width fill
        , alignBottom
        , padding 10
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , Border.color colourScheme.darkBlue
        , minimalDropShadow
        , Background.color colourScheme.darkBlue
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            , alignLeft
            ]
            [ row
                [ width fill
                , spacing 10
                ]
                [ newTabLink
                    []
                    { label =
                        el
                            []
                            (rismLogo colourScheme.white 50)
                    , url = footer.id
                    }
                , newTabLink
                    []
                    { label =
                        el
                            [ Font.color colourScheme.white ]
                            (text "View full record in RISM Online")
                    , url = footer.id
                    }
                ]
            ]
        ]


pageFooterTemplate : Session -> Language -> { a | id : String, recordHistory : RecordHistory } -> Element msg
pageFooterTemplate session language footer =
    let
        currentUrl =
            Url.toString session.url
                |> String.replace "#" "%23"

        aperoLink =
            newTabLink
                [ linkColour ]
                { label = text "API Viewer"
                , url = "/apero/?url=" ++ currentUrl
                }

        feedbackLink =
            newTabLink
                [ linkColour
                ]
                { label = text (extractLabelFromLanguageMap language localTranslations.reportAnIssue)
                , url = "https://docs.google.com/forms/d/e/1FAIpQLScZ5kDwgmraT3oMaiAA3_FYaEl_s_XpQ-t932SzUfKa63SpMg/viewform?usp=pp_url&entry.1082206543=" ++ currentUrl
                }

        muscatLinks =
            viewIf (viewMuscatLinks session) session.showMuscatLinks
    in
    row
        [ width fill
        , padding 20
        , alignBottom
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , minimalDropShadow
        , Border.color colourScheme.darkBlue
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ pageUriTemplate language headingLG footer
            , row
                [ width fill
                , alignLeft
                , spacing lineSpacing
                ]
                [ muscatLinks
                , feedbackLink
                , aperoLink
                ]
            ]
        , column
            [ width fill
            , alignRight
            , spacing lineSpacing
            ]
            [ viewRecordHistory language footer.recordHistory
            ]
        ]


pageHeaderTemplate :
    Language
    -> Maybe (Element msg)
    ->
        { a
            | label : LanguageMap
            , sectionToc : String
        }
    -> Element msg
pageHeaderTemplate language icon header =
    headerTmpl
        { body = header
        , extraAttrs =
            [ htmlAttribute (HA.id header.sectionToc)
            ]
        , hLevel = h1 language
        , icon = icon
        }


mobilePageHeaderTemplate :
    Language
    -> Maybe (Element msg)
    -> { a | label : LanguageMap }
    -> Element msg
mobilePageHeaderTemplate language icon header =
    headerTmpl
        { body = header
        , extraAttrs = []
        , hLevel = h2s language
        , icon = icon
        }


pageHeaderTemplateNoToc :
    Language
    -> Maybe (Element msg)
    ->
        { a
            | label : LanguageMap
        }
    -> Element msg
pageHeaderTemplateNoToc language icon header =
    headerTmpl
        { body = header
        , extraAttrs = []
        , hLevel = h1 language
        , icon = icon
        }


subHeaderTemplate :
    Language
    -> Maybe (Element msg)
    -> { a | label : LanguageMap }
    -> Element msg
subHeaderTemplate language icon header =
    headerTmpl
        { body = header
        , extraAttrs = []
        , hLevel = h2s language
        , icon = icon
        }


mobileSubHeaderTemplate :
    Language
    -> Maybe (Element msg)
    -> { a | label : LanguageMap }
    -> Element msg
mobileSubHeaderTemplate language icon header =
    headerTmpl
        { body = header
        , extraAttrs = []
        , hLevel = h3s language
        , icon = icon
        }


headerTmpl :
    { body : { a | label : LanguageMap }
    , extraAttrs : List (Attribute msg)
    , hLevel : LanguageMap -> Element msg
    , icon : Maybe (Element msg)
    }
    -> Element msg
headerTmpl cfg =
    row
        (width fill
            :: spacingXY 10 5
            :: centerY
            --:: clip
            :: cfg.extraAttrs
        )
        [ viewMaybe identity cfg.icon
        , cfg.hLevel (.label cfg.body)
        ]


pageLinkTemplate : Language -> LanguageMap -> Attribute msg -> { a | id : String } -> Element msg
pageLinkTemplate language langMap fontSize body =
    row
        [ width fill
        , alignLeft
        , spacing 5
        ]
        [ column
            [ width shrink ]
            [ row
                [ width fill ]
                [ el
                    [ fontSize
                    , Font.semiBold
                    ]
                    (text (extractLabelFromLanguageMap language langMap ++ ": "))
                , resourceLink body.id
                    [ linkColour ]
                    { label =
                        el
                            [ fontSize ]
                            (text body.id)
                    , url = body.id
                    }
                ]
            ]
        , externalLinkTemplate body.id
        ]


pageFullRecordTemplate : Language -> { a | id : String } -> Element msg
pageFullRecordTemplate language body =
    pageLinkTemplate language localTranslations.fullRecord headingLG body


pageFullMobileRecordTemplate : Language -> { a | id : String } -> Element msg
pageFullMobileRecordTemplate language body =
    pageLinkTemplate language localTranslations.fullRecord headingMD body


pageUriTemplate : Language -> Attribute msg -> { a | id : String } -> Element msg
pageUriTemplate language fontSize body =
    pageLinkTemplate language localTranslations.recordURI fontSize body


viewMuscatLinks : Session -> Element msg
viewMuscatLinks session =
    let
        linkTmpl muscatUrl =
            column
                [ alignLeft
                , spacing lineSpacing
                ]
                [ row
                    []
                    [ text "Muscat: "
                    , newTabLink
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap session.language localTranslations.muscatView)
                        , url = muscatUrl
                        }
                    , text " | "
                    , newTabLink
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap session.language localTranslations.muscatEdit)
                        , url = muscatUrl ++ "/edit"
                        }
                    ]
                ]
    in
    case session.route of
        SourcePageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "sources/" ++ String.fromInt id)

        SourceContentsPageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "sources/" ++ String.fromInt id)

        PersonPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "people/" ++ String.fromInt id)

        PersonSourcePageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "people/" ++ String.fromInt id)

        InstitutionPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "institutions/" ++ String.fromInt id)

        InstitutionSourcePageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "institutions/" ++ String.fromInt id)

        _ ->
            none
