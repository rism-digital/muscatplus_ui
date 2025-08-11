module Page.UI.Record.PageTemplate exposing
    ( mobilePageHeaderTemplate
    , pageFooterTemplateRouter
    , pageFullRecordTemplate
    , pageHeaderTemplate
    , pageHeaderTemplateNoToc
    , subHeaderTemplate
    )

import Config as C
import Element exposing (Attribute, Element, alignBottom, alignLeft, alignRight, alignTop, centerY, column, el, fill, htmlAttribute, newTabLink, none, padding, paddingXY, row, spacing, spacingXY, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
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
pageFooterTemplateRouter session language body =
    if session.isFramed then
        pageFooterTemplateFramed session language body

    else
        pageFooterTemplate session language body


pageFooterTemplateFramed : Session -> Language -> { a | id : String, recordHistory : RecordHistory } -> Element msg
pageFooterTemplateFramed _ _ body =
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
                    , url = body.id
                    }
                , newTabLink
                    []
                    { label =
                        el
                            [ Font.color colourScheme.white ]
                            (text "View full record in RISM Online")
                    , url = body.id
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
            column
                [ alignLeft
                , spacing lineSpacing
                ]
                [ row
                    [ spacing 6 ]
                    [ el
                        [ Font.semiBold ]
                        (text "API Viewer:")
                    , newTabLink
                        [ linkColour ]
                        { label = text "JSON-LD"
                        , url = "/apero/?url=" ++ currentUrl ++ "&format=jsonld"
                        }
                    , newTabLink
                        [ linkColour ]
                        { label = text "MARCXML"
                        , url = "/apero/?url=" ++ currentUrl ++ "&format=marcxml"
                        }
                    ]
                ]

        feedbackLink =
            newTabLink
                [ linkColour
                , alignLeft
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
        , Border.color colourScheme.midGrey
        , htmlAttribute (HA.style "z-index" "10")
        , htmlAttribute (HA.id "ro-record-footer")
        , Region.footer
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
                , viewIf (text "|") session.showMuscatLinks
                , aperoLink
                , text "|"
                , feedbackLink
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
            , alignTop
            , paddingXY 0 10
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
        , extraAttrs =
            []
        , hLevel = h3s language
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
        , extraAttrs =
            [ paddingXY 0 10
            , centerY
            ]
        , hLevel = h2s language
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
    wrappedRow
        (width fill
            :: spacingXY 10 5
            :: alignTop
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
        [ el
            [ fontSize
            , Font.semiBold
            ]
            (text (extractLabelFromLanguageMap language langMap ++ ": "))
        , resourceLink body.id
            [ linkColour ]
            { label =
                row
                    [ fontSize
                    , spacing 5
                    ]
                    [ text body.id
                    , externalLinkTemplate body.id
                    ]
            , url = body.id
            }
        ]


pageFullRecordTemplate : Language -> { a | id : String } -> Element msg
pageFullRecordTemplate language body =
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
                    [ spacing 6 ]
                    [ el [ Font.semiBold ] (text "Muscat:")
                    , newTabLink
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap session.language localTranslations.muscatView)
                        , url = muscatUrl
                        }
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

        SourceHoldingsPageRoute sourceId _ ->
            linkTmpl (C.muscatLinkBase ++ "sources/" ++ String.fromInt sourceId)

        PersonPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "people/" ++ String.fromInt id)

        PersonSourcePageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "people/" ++ String.fromInt id)

        InstitutionPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "institutions/" ++ String.fromInt id)

        InstitutionSourcePageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "institutions/" ++ String.fromInt id)

        PublicationPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "publications/" ++ String.fromInt id)

        WorkPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "works/" ++ String.fromInt id)

        _ ->
            none
