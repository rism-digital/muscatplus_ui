module Page.Views.PersonPage.RelationshipsSection exposing (..)

import Element exposing (Element, none)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (FullSourceBody)


relationshipsSectionRouter : FullSourceBody -> Language -> Element Msg
relationshipsSectionRouter body language =
    none
