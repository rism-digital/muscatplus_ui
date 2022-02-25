module Page.Search.Views.Results.InstitutionResult exposing (..)

import Element exposing (Element, fill, none, row, spacing, width)
import Language exposing (Language, formatNumberByLanguage)
import Page.RecordTypes.Search exposing (InstitutionResultBody, InstitutionResultFlags)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.Results exposing (resultIsSelected, resultTemplate)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Style exposing (colourScheme)


viewInstitutionSearchResult : Language -> Maybe String -> InstitutionResultBody -> Element SearchMsg
viewInstitutionSearchResult language selectedResult body =
    let
        resultColours =
            resultIsSelected selectedResult body.id
    in
    resultTemplate
        { id = body.id
        , language = language
        , resultTitle = body.label
        , colours = resultColours
        , resultBody = []
        }


viewInstitutionFlags : Language -> InstitutionResultFlags -> Element msg
viewInstitutionFlags language flags =
    let
        numSources =
            if flags.numberOfSources > 0 then
                let
                    labelText =
                        if flags.numberOfSources == 1 then
                            "1 Source"

                        else
                            formatNumberByLanguage language (toFloat flags.numberOfSources) ++ " Sources"
                in
                makeFlagIcon
                    { foreground = colourScheme.white
                    , background = colourScheme.darkOrange
                    }
                    (sourcesSvg colourScheme.white)
                    labelText

            else
                none
    in
    row
        [ width fill
        , spacing 10
        ]
        [ numSources
        ]
