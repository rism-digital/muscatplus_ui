module Page.UI.Record.Previews.ExternalInstitution exposing (..)

import Element exposing (Element, none)
import Language exposing (Language)
import Page.RecordTypes.ExternalRecord exposing (ExternalInstitutionRecord, ExternalProject)


viewExternalInstitutionPreview : Language -> ExternalProject -> ExternalInstitutionRecord -> Element msg
viewExternalInstitutionPreview language project body =
    none
