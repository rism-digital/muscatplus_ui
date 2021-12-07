module Page.Record.Views.RecordHistory exposing (..)

import Element exposing (Element, column, el, row, spacing, text)
import Language exposing (Language, dateFormatter, extractLabelFromLanguageMap)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.UI.Attributes exposing (lineSpacing, widthFillHeightFill)
import Time exposing (utc)


viewRecordHistory : Language -> RecordHistory -> Element msg
viewRecordHistory language history =
    let
        createdDateFormatted =
            dateFormatter utc history.created

        updatedDateFormatted =
            dateFormatter utc history.updated

        created =
            extractLabelFromLanguageMap language history.createdLabel ++ ": " ++ createdDateFormatted

        updated =
            extractLabelFromLanguageMap language history.updatedLabel ++ ": " ++ updatedDateFormatted
    in
    row
        widthFillHeightFill
        [ column
            (List.append [ spacing lineSpacing ] widthFillHeightFill)
            [ el
                []
                (text created)
            , el
                []
                (text updated)
            ]
        ]
