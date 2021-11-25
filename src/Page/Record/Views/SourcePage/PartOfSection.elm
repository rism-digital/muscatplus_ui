module Page.Record.Views.SourcePage.PartOfSection exposing (..)

import Element exposing (Element, fill, link, row, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.SectionTemplate exposing (sectionTemplate)


viewPartOfSection : Language -> PartOfSectionBody -> Element msg
viewPartOfSection language partOf =
    let
        source =
            partOf.source

        sectionHeader =
            { sectionToc = ""
            , label = partOf.label
            }

        sectionBody =
            [ link
                [ linkColour ]
                { url = source.id
                , label = text (extractLabelFromLanguageMap language source.label)
                }
            ]
    in
    sectionTemplate language sectionHeader sectionBody
