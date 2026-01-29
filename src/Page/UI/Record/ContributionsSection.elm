module Page.UI.Record.ContributionsSection exposing (viewContributionsSection)

import Element exposing (Element, alignTop, fill, height, link, paddingXY, paragraph, row, text, width)
import Language exposing (Language, LanguageMapReplacementVariable(..), extractLabelFromLanguageMapWithVariables)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Institution exposing (Contributions, ContributionsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewContributionsSection : { language : Language } -> ContributionsSectionBody -> Element msg
viewContributionsSection cfg body =
    sectionTemplate cfg.language
        body
        [ viewMaybe (viewContribution cfg.language "person") body.people
        , viewMaybe (viewContribution cfg.language "source") body.sources
        ]


viewContribution : Language -> String -> Contributions -> Element msg
viewContribution language descr contribution =
    let
        numItems =
            String.fromInt contribution.count

        linkLabel =
            extractLabelFromLanguageMapWithVariables language
                [ LanguageMapReplacementVariable "numItems" numItems
                , LanguageMapReplacementVariable "recordType" descr
                ]
                localTranslations.viewContributedRecords
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY lineSpacing 0
        ]
        [ link
            [ linkColour ]
            { label =
                paragraph
                    []
                    [ text linkLabel ]
            , url = contribution.url
            }
        ]
