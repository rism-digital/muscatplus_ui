module Desktop.Record.PageShell exposing (viewDesktopRecordPage)

import Element exposing (Element, alignTop, clipY, column, fill, height, row, width)
import Element.Background as Background
import Element.Region as Region
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.UI.Record.TabShell exposing (TabBody)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplateNoToc, recordHeaderTemplate, subHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewDesktopRecordPage :
    { session : Session
    , body : { a | id : String, label : LanguageMap, recordHistory : RecordHistory }
    , icon : Element msg
    , selectedBody : TabBody msg
    , tabBar : Element msg
    }
    -> Element msg
viewDesktopRecordPage { session, body, icon, selectedBody, tabBar } =
    let
        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplateNoToc session.language (Just icon) body

        headerItems =
            if session.isFramed then
                [ pageHeader ]

            else
                [ pageHeader, tabBar ]
    in
    row
        [ width fill
        , height fill
        , Region.mainContent
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ recordHeaderTemplate selectedBody.showBottomShadow headerItems
            , selectedBody.bodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]
