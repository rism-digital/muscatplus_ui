module Page.Views.PersonPage.FullRecordPage exposing (..)

import Element exposing (Element, column, el, fill, height, link, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Components exposing (h4)
import Page.UI.Style exposing (colourScheme)
import Page.Views.PersonPage.ExternalAuthoritiesSection exposing (viewExternalAuthoritiesRouter)
import Page.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsRouter)
import Page.Views.PersonPage.RelationshipsSection exposing (viewPersonRelationshipsRouter)
import Page.Views.PersonPage.SummarySection exposing (viewSummaryRouter)


viewFullPersonPage : PersonBody -> Language -> Element Msg
viewFullPersonPage body language =
    let
        recordUri =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
                    { url = body.id
                    , label = text body.id
                    }
                ]

        extAuthorities =
            viewExternalAuthoritiesRouter body language
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
            , extAuthorities
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\viewFunc -> viewFunc body language)
                        [ viewSummaryRouter
                        , viewNameVariantsRouter
                        , viewPersonRelationshipsRouter
                        ]
                    )
                ]
            ]
        ]
