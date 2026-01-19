module Page.UI.Record.ContributionsSection exposing (..)

import Element exposing (Element, fill, link, none, paragraph, row, text, width)
import Language exposing (Language)
import Page.RecordTypes.Institution exposing (Contributions, ContributionsSectionBody)
import Page.UI.Attributes exposing (linkColour)
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
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { url = contribution.search
            , label =
                paragraph
                    []
                    [ text ("View " ++ String.fromInt contribution.count ++ " " ++ descr ++ " records contributed by this project.") ]
            }
        ]
