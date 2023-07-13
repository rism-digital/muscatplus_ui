module Page.UI.Record.Previews.ExternalPerson exposing (..)

import Element exposing (Element, none)
import Language exposing (Language)
import Page.RecordTypes.ExternalRecord exposing (ExternalPersonRecord, ExternalProject)


viewExternalPersonPreview : Language -> ExternalProject -> ExternalPersonRecord -> Element msg
viewExternalPersonPreview language project body =
    none
