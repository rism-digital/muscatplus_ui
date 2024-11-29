module Page.UI.Record.WorksSection exposing (viewPersonWorksSection, viewSourceWorksSection)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, indexedTable, link, newTabLink, none, padding, paddingXY, row, spacing, table, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Page.RecordTypes.Works exposing (PersonExternalWorkReferencesBody, PersonWorksSectionBody, SourceWorksSectionBody, WorkReference)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (externalLinkTemplate, h3s, renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)


viewSourceWorksSection : Language -> SourceWorksSectionBody -> Element msg
viewSourceWorksSection language worksSection =
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
                [ viewMaybe (viewSourceWorkReferenceSection language) worksSection.workReference
                ]
            ]
        ]


viewSourceWorkReferenceSection : Language -> WorkReference -> Element msg
viewSourceWorkReferenceSection language workReference =
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
                [ viewMaybe (viewPersonExternalWorkReferencesSection language) worksSection.workReferences
                ]
            ]
        ]


viewPersonExternalWorkReferencesSection : Language -> PersonExternalWorkReferencesBody -> Element msg
viewPersonExternalWorkReferencesSection language workReferences =
    let
        cycleBg i =
            if modBy 2 i == 0 then
                Background.color colourScheme.lightestBlue

            else
                Background.color colourScheme.white

        headerStyles =
            [ Font.semiBold
            , padding 10
            , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
            , Border.color colourScheme.midGrey
            , Background.color colourScheme.lightGrey
            ]
    in
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , spacing 5
                ]
                [ h3s language workReferences.label
                ]
            , row
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
                        { data = workReferences.items
                        , columns =
                            [ { header =
                                    el
                                        headerStyles
                                        (text "Work title")
                              , width = fill
                              , view = \i w -> el [ cycleBg i, padding 10 ] (text w.value)
                              }
                            , { header = el headerStyles (text "Sources")
                              , width = fill
                              , view = \i w -> link [ cycleBg i, padding 10, linkColour ] { url = w.searchUrl, label = text "Find in RISM Online" }
                              }
                            , { header = el headerStyles (text "External authority")
                              , width = fill
                              , view = \i w -> newTabLink [ cycleBg i, padding 10, linkColour ] { url = w.authorityUrl, label = text w.externalIdentifier }
                              }
                            ]
                        }
                    ]
                ]
            ]
        ]
