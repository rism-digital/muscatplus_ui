module Page.UI.Record.WorksSection exposing (viewPersonWorksSection, viewSourceWorksSection)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, indexedTable, link, newTabLink, none, padding, paddingXY, paragraph, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Page.RecordTypes.Work exposing (PersonExternalWorkReferencesBody, PersonWorksSectionBody, SourceWorksSectionBody, WorkReference, WorksCatalogue, WorksCatalogueSectionBody)
import Page.UI.Attributes exposing (cycleTableBackground, lineSpacing, linkColour, sectionBorderStyles, tableHeaderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (externalLinkTemplate, h3s, viewPreRenderedSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)


viewSourceWorksSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> SourceWorksSectionBody
    -> Element msg
viewSourceWorksSection { language, preRenderedFormatter } worksSection =
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
                [ viewMaybe (viewSourceWorkReferenceSection { language = language, preRenderedFormatter = preRenderedFormatter }) worksSection.workReference
                ]
            ]
        ]


viewSourceWorkReferenceSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> WorkReference
    -> Element msg
viewSourceWorkReferenceSection { language } workReference =
    let
        preRendered =
            [ text workReference.value
            , link
                [ linkColour ]
                { label = text (extractLabelFromLanguageMap language (toLanguageMap "Sources linked to") ++ " " ++ workReference.externalIdentifier)
                , url = workReference.searchUrl
                }
            , row
                [ width fill
                , alignLeft
                , spacing 5
                ]
                [ newTabLink
                    [ linkColour ]
                    { label = text (extractLabelFromLanguageMap language (toLanguageMap "External work authority") ++ " " ++ workReference.externalIdentifier)
                    , url = workReference.authorityUrl
                    }
                , externalLinkTemplate workReference.authorityUrl
                ]
            ]
    in
    viewPreRenderedSummaryField language [ { label = workReference.label, value = preRendered } ]


viewPersonWorksSection : Language -> PersonWorksSectionBody -> Element msg
viewPersonWorksSection language worksSection =
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
                [ viewMaybe (viewPersonWorksCatalogueSection language) worksSection.worksCatalogs
                , viewMaybe (viewPersonExternalWorkReferencesSection language) worksSection.workReferences
                ]
            ]
        ]


viewPersonExternalWorkReferencesSection : Language -> PersonExternalWorkReferencesBody -> Element msg
viewPersonExternalWorkReferencesSection language workReferences =
    sectionTemplate language
        workReferences
        [ row
            (width fill :: sectionBorderStyles)
            [ column
                [ spacing lineSpacing
                , width fill
                , height fill
                , alignTop
                ]
                [ row
                    [ width fill ]
                    [ column
                        [ width fill
                        , height fill
                        , alignTop
                        , spacing lineSpacing
                        , paddingXY lineSpacing 10
                        ]
                        [ indexedTable
                            [ Border.width 1
                            , Border.color colourScheme.midGrey
                            ]
                            { columns =
                                [ { header =
                                        el
                                            tableHeaderStyles
                                            (text "Work title")
                                  , width = fill
                                  , view = \i w -> el [ cycleTableBackground i, padding 10 ] (text w.value)
                                  }
                                , { header = el tableHeaderStyles (text "Source count")
                                  , width = fill
                                  , view =
                                        \i w ->
                                            el
                                                [ cycleTableBackground i, padding 10 ]
                                                (text (String.fromInt w.sourceCount))
                                  }
                                , { header = el tableHeaderStyles (text "Sources")
                                  , width = fill
                                  , view =
                                        \i w ->
                                            link
                                                [ cycleTableBackground i, padding 10, linkColour ]
                                                { label = text ("Sources linked to " ++ w.externalIdentifier), url = w.searchUrl }
                                  }
                                , { header = el tableHeaderStyles (text "External authority")
                                  , width = fill
                                  , view =
                                        \i w ->
                                            newTabLink
                                                [ cycleTableBackground i, padding 10, linkColour ]
                                                { label = text w.externalIdentifier, url = w.authorityUrl }
                                  }
                                ]
                            , data = workReferences.items
                            }
                        ]
                    ]
                ]
            ]
        ]


viewPersonWorksCatalogueSection : Language -> WorksCatalogueSectionBody -> Element msg
viewPersonWorksCatalogueSection language catalogues =
    sectionTemplate language
        catalogues
        [ row
            (width fill :: sectionBorderStyles)
            [ column
                [ spacing lineSpacing
                , width fill
                , height fill
                , alignTop
                ]
                [ row
                    [ width fill ]
                    [ column
                        (spacing lineSpacing :: valueFieldColumnAttributes)
                        (List.map (viewWorksCatalogue language) catalogues.items)
                    ]
                ]
            ]
        ]


viewWorksCatalogue : Language -> WorksCatalogue -> Element msg
viewWorksCatalogue language catalogue =
    row
        [ width fill
        , alignLeft
        , spacing 5
        ]
        [ link
            [ linkColour ]
            { label = paragraph [] [ text (extractLabelFromLanguageMap language catalogue.label) ]
            , url = catalogue.id
            }
        ]
