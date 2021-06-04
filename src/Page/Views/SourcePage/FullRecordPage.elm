module Page.Views.SourcePage.FullRecordPage exposing (..)

import Element exposing (Element, alignRight, column, el, fill, height, htmlAttribute, inFront, link, none, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Components exposing (h4)
import Page.UI.Style exposing (colourScheme)
import Page.Views.SourcePage.ContentsSection exposing (viewContentsRouter)
import Page.Views.SourcePage.ExemplarsSection exposing (viewExemplarsRouter)
import Page.Views.SourcePage.MaterialGroupsSection exposing (viewMaterialGroupsRouter)
import Page.Views.SourcePage.PartOfSection exposing (viewPartOfRouter)
import Page.Views.SourcePage.SourceItemsSection exposing (viewSourceItemsRouter)


viewFullSourcePage : FullSourceBody -> Language -> Element Msg
viewFullSourcePage body language =
    let
        recordUri =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
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
            , recordUri
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , htmlAttribute (HA.id body.sectionToc)
                    ]
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
