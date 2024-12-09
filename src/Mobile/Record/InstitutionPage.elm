module Mobile.Record.InstitutionPage exposing (viewFullMobileInstitutionPage)

import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Maybe.Extra as ME
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewMobileParagraphField, viewMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.LocationSection exposing (viewLocationAddressSection, viewLocationMapSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobileInstitutionPage :
    Session
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewFullMobileInstitutionPage session _ body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (institutionSvg colourScheme.darkBlue)

        isEmpty =
            ME.isNothing body.organizationDetails
                && ME.isNothing body.location
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources
                && ME.isNothing body.externalAuthorities
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ row
                [ width fill
                , paddingXY 10 10
                , Border.widthEach { bottom = 4, left = 0, right = 0, top = 0 }
                , htmlAttribute (HA.style "border-bottom-style" "double")
                , Border.color colourScheme.midGrey
                ]
                [ mobilePageHeaderTemplate session.language (Just icon) body ]
            , row
                [ width fill
                , height fill
                , alignTop
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , alignTop
                    , padding 20
                    , spacing sectionSpacing
                    ]
                    (pageBodyOrEmpty session.language
                        isEmpty
                        [ viewMaybe
                            (viewOrganizationDetailsSection
                                { language = session.language
                                , summaryFormatter = viewMobileSummaryField
                                }
                            )
                            body.organizationDetails
                        , viewMaybe
                            (viewLocationAddressSection
                                { language = session.language
                                , summaryFormatter = viewMobileSummaryField
                                }
                            )
                            body.location
                        , viewMaybe
                            (viewRelationshipsSection
                                { language = session.language
                                , relationshipFormatter = viewMobileRelationshipBody
                                }
                            )
                            body.relationships
                        , viewMaybe
                            (viewNotesSection
                                { language = session.language
                                , paragraphFormatter = viewMobileParagraphField
                                }
                            )
                            body.notes
                        , viewMaybe (viewExternalResourcesSection session.language) body.externalResources
                        , viewMaybe (viewExternalAuthoritiesSection session.language) body.externalAuthorities
                        , viewMaybe
                            (viewLocationMapSection
                                { language = session.language
                                , summaryFormatter = viewMobileSummaryField
                                }
                                session.window
                            )
                            body.location
                        ]
                    )
                ]
            ]
        ]
