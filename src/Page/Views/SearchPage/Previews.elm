module Page.Views.SearchPage.Previews exposing (..)

import Element exposing (Element, column, el, fill, height, link, none, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Components exposing (h4)
import Page.UI.Style exposing (colourScheme)
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

        _ ->
            viewUnknownPreview


viewUnknownPreview : Element Msg
viewUnknownPreview =
    none
