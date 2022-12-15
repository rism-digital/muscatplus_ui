module Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageFullRecordTemplate, pageHeaderTemplate, pageUriTemplate)

import Config as C
import Element
    exposing
        ( Element
        , alignBottom
        , alignLeft
        , alignRight
        , column
        , el
        , fill
        , htmlAttribute
        , link
        , none
        , padding
        , row
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.Route exposing (Route(..))
import Page.UI.Attributes exposing (headingSM, lineSpacing, linkColour)
import Page.UI.Components exposing (h1)
import Page.UI.Record.RecordHistory exposing (viewRecordHistory)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)
import Url


pageFooterTemplate : Session -> Language -> { a | recordHistory : RecordHistory, id : String } -> Element msg
pageFooterTemplate session language footer =
    let
        currentUrl =
            Url.toString session.url
                |> String.replace "#" "%23"

        feedbackLink =
            link
                [ linkColour
                ]
                { label = text (extractLabelFromLanguageMap language localTranslations.reportAnIssue)
                , url = "https://docs.google.com/forms/d/e/1FAIpQLScZ5kDwgmraT3oMaiAA3_FYaEl_s_XpQ-t932SzUfKa63SpMg/viewform?usp=pp_url&entry.1082206543=" ++ currentUrl
                }

        muscatLinks =
            if session.showMuscatLinks then
                viewMuscatLinks session

            else
                none
    in
    row
        [ width fill
        , padding 20
        , alignBottom
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 2 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , Background.color (colourScheme.cream |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ pageUriTemplate language footer
            , row
                [ width fill
                , alignLeft
                , spacing lineSpacing
                ]
                [ muscatLinks
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


pageHeaderTemplate : Language -> { a | sectionToc : String, label : LanguageMap } -> Element msg
pageHeaderTemplate language header =
    row
        [ width fill
        , htmlAttribute (HA.id header.sectionToc)
        ]
        [ h1 language header.label ]


pageLinkTemplate : Language -> LanguageMap -> { a | id : String } -> Element msg
pageLinkTemplate language langMap body =
    row
        [ width fill
        , alignLeft
        ]
        [ el
            [ headingSM
            , Font.semiBold
            ]
            (text (extractLabelFromLanguageMap language langMap ++ ": "))
        , link
            [ linkColour ]
            { label =
                el
                    [ headingSM ]
                    (text body.id)
            , url = body.id
            }
        ]


pageFullRecordTemplate : Language -> { a | id : String } -> Element msg
pageFullRecordTemplate language body =
    pageLinkTemplate language localTranslations.fullRecord body


pageUriTemplate : Language -> { a | id : String } -> Element msg
pageUriTemplate language body =
    pageLinkTemplate language localTranslations.recordURI body


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
                    , link
                        [ linkColour ]
                        { label = text "View"
                        , url = muscatUrl
                        }
                    , text " | "
                    , link
                        [ linkColour ]
                        { label = text "Edit"
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
