module Page.UI.Record.RecordHistory exposing (viewRecordHistory)

import Element exposing (Element, alignRight, alignTop, column, el, fill, height, row, spacing, text, width)
import Language exposing (Language, dateFormatter, extractLabelFromLanguageMap)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.UI.Attributes exposing (lineSpacing)
import Time exposing (utc)


viewRecordHistory : Language -> RecordHistory -> Element msg
viewRecordHistory language history =
    let
        created =
            extractLabelFromLanguageMap language history.createdLabel ++ ": " ++ createdDateFormatted

        createdDateFormatted =
            dateFormatter utc history.created

        updated =
            extractLabelFromLanguageMap language history.updatedLabel ++ ": " ++ updatedDateFormatted

        updatedDateFormatted =
            dateFormatter utc history.updated
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ el
                [ alignRight ]
                (text created)
            , el
                [ alignRight ]
                (text updated)
            ]
        ]
