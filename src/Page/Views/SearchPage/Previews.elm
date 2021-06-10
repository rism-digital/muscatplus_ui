module Page.Views.SearchPage.Previews exposing (..)

import Element exposing (Element, none)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.Response exposing (ServerData(..))
import Page.Views.SearchPage.Previews.Incipit exposing (viewIncipitPreview)
import Page.Views.SearchPage.Previews.Institution exposing (viewInstitutionPreview)
import Page.Views.SearchPage.Previews.Person exposing (viewPersonPreview)
import Page.Views.SearchPage.Previews.Source exposing (viewSourcePreview)


viewPreviewRouter : Language -> ServerData -> Element Msg
viewPreviewRouter language previewData =
    case previewData of
        SourceData body ->
            viewSourcePreview body language

        PersonData body ->
            viewPersonPreview body language

        InstitutionData body ->
            viewInstitutionPreview body language

        IncipitData body ->
            viewIncipitPreview body language

        _ ->
            viewUnknownPreview


viewUnknownPreview : Element Msg
viewUnknownPreview =
    none
