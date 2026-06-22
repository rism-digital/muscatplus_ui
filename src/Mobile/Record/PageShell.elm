module Mobile.Record.PageShell exposing (viewMobileRecordPage)

import Element exposing (Element, alignTop, clipY, column, fill, height, row, width)
import Element.Background as Background
import Language exposing (LanguageMap)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewMobileRecordPage :
    { session : Session
    , body : { a | label : LanguageMap }
    , icon : Element msg
    , topBar : Element msg
    , bodyView : Element msg
    }
    -> Element msg
viewMobileRecordPage { session, body, icon, topBar, bodyView } =
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
            [ column
                [ width fill
                , minimalDropShadow
                ]
                [ row
                    [ width fill
                    , Element.paddingXY 10 10
                    ]
                    [ mobilePageHeaderTemplate session.language (Just icon) body ]
                , topBar
                ]
            , bodyView
            ]
        ]
