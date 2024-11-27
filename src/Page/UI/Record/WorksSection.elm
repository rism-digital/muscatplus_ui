module Page.UI.Record.WorksSection exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, fill, height, link, newTabLink, none, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Page.RecordTypes.Works exposing (WorkReference, WorksSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (externalLinkTemplate, renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewWorksSection : Language -> WorksSectionBody -> Element msg
viewWorksSection language worksSection =
    sectionTemplate language
        worksSection
        [ row
            (List.append
                [ width fill
                , height fill
                , alignTop
                ]
                sectionBorderStyles
            )
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                [ viewMaybe (viewWorkReferenceSection language) worksSection.workReference
                ]
            ]
        ]


viewWorkReferenceSection : Language -> WorkReference -> Element msg
viewWorkReferenceSection language workReference =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            labelFieldColumnAttributes
            [ renderLabel language workReference.label ]
        , column
            valueFieldColumnAttributes
            [ text workReference.value
            , link
                [ linkColour ]
                { label = text (extractLabelFromLanguageMap language (toLanguageMap "Search in RISM Online"))
                , url = workReference.searchUrl
                }
            , row
                [ width fill
                , alignLeft
                , spacing 5
                ]
                [ newTabLink
                    [ linkColour ]
                    { label = text (extractLabelFromLanguageMap language (toLanguageMap "External work authority"))
                    , url = workReference.authorityUrl
                    }
                , externalLinkTemplate workReference.authorityUrl
                ]
            ]
        ]
