module Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate, pageUriTemplate, viewMuscatLinks)

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
import Html.Attributes as HTA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.Route exposing (Route(..))
import Page.UI.Attributes exposing (headingSM, lineSpacing, linkColour)
import Page.UI.Components exposing (h1)
import Page.UI.Record.RecordHistory exposing (viewRecordHistory)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)


pageFooterTemplate : Session -> Language -> { a | recordHistory : RecordHistory, id : String } -> Element msg
pageFooterTemplate session language footer =
    let
        muscatLinks =
            if session.showMuscatLinks then
                row
                    [ width fill
                    , alignLeft
                    ]
                    [ viewMuscatLinks session ]

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
            , muscatLinks
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
        , htmlAttribute (HTA.id header.sectionToc)
        ]
        [ h1 language header.label ]


pageUriTemplate : Language -> { a | id : String } -> Element msg
pageUriTemplate language body =
    row
        [ width fill
        , alignLeft
        ]
        [ el
            [ headingSM
            ]
            (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
        , link
            [ linkColour ]
            { label = el [ headingSM ] (text body.id)
            , url = body.id
            }
        ]


viewMuscatLinks : Session -> Element msg
viewMuscatLinks session =
    let
        linkTmpl muscatUrl =
            column
                [ alignLeft
                , width fill
                , spacing lineSpacing
                ]
                [ row
                    [ width fill ]
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
            linkTmpl <| C.muscatLinkBase ++ "sources/" ++ String.fromInt id

        SourceContentsPageRoute id _ ->
            linkTmpl <| C.muscatLinkBase ++ "sources/" ++ String.fromInt id

        PersonPageRoute id ->
            linkTmpl <| C.muscatLinkBase ++ "people/" ++ String.fromInt id

        PersonSourcePageRoute id _ ->
            linkTmpl <| C.muscatLinkBase ++ "people/" ++ String.fromInt id

        InstitutionPageRoute id ->
            linkTmpl <| C.muscatLinkBase ++ "institutions/" ++ String.fromInt id

        InstitutionSourcePageRoute id _ ->
            linkTmpl <| C.muscatLinkBase ++ "institutions/" ++ String.fromInt id

        _ ->
            none
