module Page.RecordTypes.PublicationList exposing (PublicationListBody, publicationListBodyDecoder)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Publication exposing (BasicPublicationBody, basicPublicationBodyDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias PublicationListBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , items : List BasicPublicationBody
    }


publicationListBodyDecoder : Decoder PublicationListBody
publicationListBodyDecoder =
    Decode.succeed PublicationListBody
        |> hardcoded "publication-list-body"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (list basicPublicationBodyDecoder)
