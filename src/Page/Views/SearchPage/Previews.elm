module Page.Views.SearchPage.Previews exposing (..)

import Element exposing (Element, column, el, fill, height, link, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Source exposing (FullSourceBody, PartOfSectionBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Components exposing (h4, h5)
import Page.UI.Style exposing (colourScheme)
import Page.Views.SourcePage.ContentsSection exposing (viewContentsRouter)
import Page.Views.SourcePage.PartOfSection exposing (viewPartOfRouter, viewPartOfSection)


viewPreviewRouter : ServerData -> Language -> Element Msg
viewPreviewRouter previewData language =
    case previewData of
        SourceData body ->
            viewSourcePreview body language

        PersonData body ->
            viewPersonPreview body language

        _ ->
            viewUnknownPreview


viewSourcePreview : FullSourceBody -> Language -> Element Msg
viewSourcePreview body language =
    let
        fullSourceLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
                    { url = body.id, label = text body.id }
                ]
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 5
            ]
            [ row
                [ width fill ]
                [ h4 language body.label ]
            , fullSourceLink
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\viewFunc -> viewFunc body language)
                        [ viewPartOfRouter
                        , viewContentsRouter
                        ]
                    )
                ]
            ]
        ]


viewPersonPreview : PersonBody -> Language -> Element Msg
viewPersonPreview body language =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill ]
                [ h5 language body.label ]
            , row
                [ width fill ]
                [ text body.id ]
            ]
        ]


viewUnknownPreview : Element Msg
viewUnknownPreview =
    none
