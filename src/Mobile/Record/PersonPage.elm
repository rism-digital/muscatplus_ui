module Mobile.Record.PersonPage exposing (viewFullMobilePersonPage)

import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Maybe.Extra as ME
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewMobileParagraphField, viewMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewPersonWorksSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobilePersonPage :
    Session
    -> RecordPageModel RecordMsg
    -> PersonBody
    -> Element RecordMsg
viewFullMobilePersonPage session _ body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (peopleSvg colourScheme.darkBlue)

        isEmpty =
            ME.isNothing body.biographicalDetails
                && ME.isNothing body.nameVariants
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
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , padding 20
                    , spacing sectionSpacing
                    ]
                    (pageBodyOrEmpty
                        session.language
                        isEmpty
                        [ viewMaybe
                            (viewBiographicalDetailsSection
                                { language = session.language
                                , summaryFormatter = viewMobileSummaryField
                                }
                            )
                            body.biographicalDetails
                        , viewMaybe
                            (viewNameVariantsSection
                                { language = session.language
                                , summaryFormatter = viewMobileSummaryField
                                }
                            )
                            body.nameVariants
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
                        , viewMaybe (viewPersonWorksSection session.language) body.works
                        ]
                    )
                ]
            ]
        ]
