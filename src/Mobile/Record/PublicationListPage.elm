module Mobile.Record.PublicationListPage exposing (viewMobilePublicationListPage)

import Element exposing (Element, alignLeft, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, link, padding, paddingEach, paddingXY, paragraph, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Publication exposing (BasicPublicationBody)
import Page.RecordTypes.PublicationList exposing (PublicationListBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing)
import Page.UI.Components exposing (formatPublicationStatusBadge)
import Page.UI.Images exposing (folderMusicSvg)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewMobilePublicationListPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationListBody
    -> Element RecordMsg
viewMobilePublicationListPage session _ body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (folderMusicSvg colourScheme.darkBlue)
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ row
                [ width fill
                , paddingXY 10 10
                ]
                [ mobilePageHeaderTemplate session.language (Just icon) body ]
            , row
                [ width fill
                , height fill
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , paddingEach { bottom = 90, left = 20, right = 20, top = 20 }
                    , spacing sectionSpacing
                    ]
                    (List.map (viewPublicationCard session.language) body.items)
                ]
            ]
        ]


viewPublicationCard : Language -> BasicPublicationBody -> Element RecordMsg
viewPublicationCard language publication =
    let
        shortTitle =
            Maybe.map .shortTitle publication.properties
                |> ME.join
                |> Maybe.map (extractLabelFromLanguageMap language)

        publicationYear =
            Maybe.map .publicationDates publication.properties
                |> ME.join
                |> Maybe.map (extractLabelFromLanguageMap language)

        composer =
            Maybe.map (\c -> extractLabelFromLanguageMap language c.label) publication.composer
                |> Maybe.withDefault "[No composer]"
    in
    row
        [ width fill
        , Border.width 1
        , Border.color colourScheme.midGrey
        , Border.rounded 4
        , padding 12
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ link
                [ linkColour
                , alignLeft
                , width fill
                , htmlAttribute (HA.style "overflow-wrap" "anywhere")
                ]
                { label = paragraph [ width fill ] [ text (extractLabelFromLanguageMap language publication.label) ]
                , url = publication.id
                }
            , paragraph [] [ text composer ]
            , maybeField "Short Title" shortTitle
            , maybeField "Publication Year" publicationYear
            , formatPublicationStatusBadge language publication.status
            ]
        ]


maybeField : String -> Maybe String -> Element msg
maybeField label value =
    case value of
        Just fieldValue ->
            paragraph [] [ text (label ++ ": " ++ fieldValue) ]

        Nothing ->
            text ""
