module Page.Record.Views.PlacePage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, column, fill, none, row, spacing, width)
import Language exposing (Language)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)
import Page.RecordTypes.Place exposing (PlaceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing, widthFillHeightFill)


viewFullPlacePage :
    Language
    -> RecordPageModel
    -> PlaceBody
    -> Element RecordMsg
viewFullPlacePage language model body =
    row
        widthFillHeightFill
        [ column
            (List.append [ spacing sectionSpacing ] widthFillHeightFill)
            [ row
                [ width fill
                , alignTop
                ]
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ pageHeaderTemplate language body
                    , pageUriTemplate language body
                    ]
                ]
            ]
        ]
