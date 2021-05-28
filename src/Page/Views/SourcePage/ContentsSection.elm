module Page.Views.SourcePage.ContentsSection exposing (..)

import Element exposing (Element, none)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (ContentsSectionBody, FullSourceBody)


viewContentsRouter : FullSourceBody -> Language -> Element Msg
viewContentsRouter body language =
    case body.contents of
        Just contentsSection ->
            viewContentsSection contentsSection language

        Nothing ->
            none


viewContentsSection : ContentsSectionBody -> Language -> Element Msg
viewContentsSection contents language =
    none
