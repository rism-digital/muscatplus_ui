module Page.Views.PersonPage.SummarySection exposing (..)

import Element exposing (Element, none)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Components exposing (viewSummaryField)


viewSummaryRouter : PersonBody -> Language -> Element Msg
viewSummaryRouter body language =
    case body.summary of
        Just sum ->
            viewSummaryField language sum

        Nothing ->
            none
