module Page.UI.Record.ContributionsSection exposing (..)

import Element exposing (Element, alignTop, fill, height, link, none, paddingXY, paragraph, row, text, width)
import Language exposing (Language)
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
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY lineSpacing 0
        ]
        [ link
            [ linkColour ]
            { url = contribution.search
            , label =
                paragraph
                    []
                    [ text ("View " ++ String.fromInt contribution.count ++ " " ++ descr ++ " records contributed by this project.") ]
            }
        ]
