module Page.Views.SearchPage.Previews exposing (..)

import Element exposing (Element, column, el, fill, height, link, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Source exposing (FullSourceBody, PartOfSectionBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Components exposing (h4, h5)
import Page.UI.Style exposing (colourScheme)
import Page.Views.SourcePage.ContentsSection exposing (viewContentsRouter)
import Page.Views.SourcePage.ExemplarsSection exposing (viewExemplarsRouter)
import Page.Views.SourcePage.MaterialGroupsSection exposing (viewMaterialGroupsRouter)
import Page.Views.SourcePage.PartOfSection exposing (viewPartOfRouter, viewPartOfSection)
import Page.Views.SourcePage.SourceItemsSection exposing (viewSourceItemsRouter)


viewPreviewRouter : ServerData -> Language -> Element Msg
viewPreviewRouter previewData language =
    case previewData of
        SourceData body ->
            viewSourcePreview body language

        PersonData body ->
            viewPersonPreview body language

        InstitutionData body ->
            viewInstitutionPreview body language

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
                        , viewExemplarsRouter
                        , viewMaterialGroupsRouter
                        , viewSourceItemsRouter
                        ]
                    )
                ]
            ]
        ]


viewPersonPreview : PersonBody -> Language -> Element Msg
viewPersonPreview body language =
    let
        personLink =
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
            , personLink
            ]
        ]


viewInstitutionPreview : InstitutionBody -> Language -> Element msg
viewInstitutionPreview body language =
    let
        institutionLink =
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
            , institutionLink
            ]
        ]


viewUnknownPreview : Element Msg
viewUnknownPreview =
    none
