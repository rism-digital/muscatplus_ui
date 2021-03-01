module Records.Views.Institution exposing (..)

import Api.Records exposing (InstitutionBody)
import Element exposing (Element, column, el, text)
import Language exposing (Language, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Msg)


viewInstitutionRecord : InstitutionBody -> Language -> Element Msg
viewInstitutionRecord body language =
    column [] [ el [] (text (extractLabelFromLanguageMap language body.label)) ]
