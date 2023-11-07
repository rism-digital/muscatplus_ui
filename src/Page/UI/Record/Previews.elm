module Page.UI.Record.Previews exposing (PreviewConfig, viewPreviewError, viewPreviewRouter)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, maximum, minimum, moveDown, none, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Http.Detailed
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Error.Views exposing (createErrorMessage)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (minimalDropShadow, resultsColumnWidth, sectionSpacing, sidebarWidth)
import Page.UI.Components exposing (h4)
import Page.UI.Images exposing (closeWindowSvg, spinnerSvg)
import Page.UI.Record.Previews.ExternalInstitution exposing (viewExternalInstitutionPreview)
import Page.UI.Record.Previews.ExternalPerson exposing (viewExternalPersonPreview)
import Page.UI.Record.Previews.ExternalSource exposing (viewExternalSourcePreview)
import Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)
import Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)
import Page.UI.Record.Previews.Person exposing (viewPersonPreview)
import Page.UI.Record.Previews.Source exposing (viewSourcePreview)
import Page.UI.Style exposing (colourScheme)
import Response exposing (ServerData(..))
import Set exposing (Set)


type alias PreviewConfig msg =
    { language : Language
    , windowSize : ( Int, Int )
    , closeMsg : msg
    , sourceItemExpandMsg : msg
    , sourceItemsExpanded : Bool
    , incipitInfoSectionsExpanded : Set String
    , incipitInfoToggleMsg : String -> msg
    }


viewPreviewError :
    { closeMsg : msg
    , errorMessage : Http.Detailed.Error String
    , language : Language
    , windowSize : ( Int, Int )
    }
    -> Element msg
viewPreviewError cfg =
    let
        ( _, windowHeight ) =
            cfg.windowSize

        ( mainMessage, details ) =
            createErrorMessage cfg.language cfg.errorMessage

        messageDetails =
            Maybe.withDefault "" details

        previewHeight =
            round (toFloat windowHeight * 0.6)

        moveDownAmount =
            toFloat windowHeight * 0.08
    in
    row
        [ width (fill |> minimum 600 |> maximum 800)
        , height (fill |> maximum previewHeight)
        , clipY
        , alignTop
        , alignLeft
        , Background.color colourScheme.white
        , Border.color colourScheme.darkBlue
        , Border.width 3
        , htmlAttribute (HA.style "z-index" "10")
        , moveDown moveDownAmount
        , minimalDropShadow
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color colourScheme.white
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
            ]
            [ viewRecordPreviewTitleBar cfg.language cfg.closeMsg
            , row
                [ width fill
                , height fill
                , scrollbarY
                ]
                [ paragraph
                    [ centerX
                    , centerY
                    , padding 20
                    ]
                    [ el [ width fill ] (text mainMessage)
                    , el [ width fill ] (text messageDetails)
                    ]
                ]
            ]
        ]


viewPreviewLoading : Element msg
viewPreviewLoading =
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        ]
        [ column
            [ width fill
            , height fill
            , spacing sectionSpacing
            ]
            [ row
                [ width fill
                , height fill
                , alignTop
                ]
                [ el
                    [ width (px 25)
                    , height (px 25)
                    , centerY
                    , centerX
                    ]
                    (animatedLoader
                        [ width (px 40), height (px 40) ]
                        (spinnerSvg colourScheme.midGrey)
                    )
                ]
            ]
        ]


viewPreviewRouter : PreviewConfig msg -> Maybe ServerData -> Element msg
viewPreviewRouter cfg previewData =
    let
        ( windowWidth, windowHeight ) =
            cfg.windowSize

        previewHeight =
            round (toFloat windowHeight * 0.8)

        previewWidth =
            round (toFloat (windowWidth - (sidebarWidth + resultsColumnWidth)) * 0.8)

        preview =
            case previewData of
                Just (SourceData body) ->
                    viewSourcePreview
                        { expandMsg = cfg.sourceItemExpandMsg
                        , incipitInfoExpanded = cfg.incipitInfoSectionsExpanded
                        , incipitInfoToggleMsg = cfg.incipitInfoToggleMsg
                        , itemsExpanded = cfg.sourceItemsExpanded
                        , language = cfg.language
                        }
                        body

                Just (PersonData body) ->
                    viewPersonPreview cfg.language body

                Just (InstitutionData body) ->
                    viewInstitutionPreview cfg.language body

                Just (IncipitData body) ->
                    viewIncipitPreview
                        { incipitInfoExpanded = cfg.incipitInfoSectionsExpanded
                        , infoToggleMsg = cfg.incipitInfoToggleMsg
                        , language = cfg.language
                        }
                        body

                Just (ExternalData body) ->
                    case body.record of
                        ExternalSource sourceBody ->
                            viewExternalSourcePreview cfg.language body.project sourceBody

                        ExternalPerson personBody ->
                            viewExternalPersonPreview cfg.language body.project personBody

                        ExternalInstitution institutionBody ->
                            viewExternalInstitutionPreview cfg.language body.project institutionBody

                Nothing ->
                    viewPreviewLoading

                _ ->
                    none
    in
    row
        [ width (px previewWidth |> maximum 1100)
        , height (fill |> maximum previewHeight)
        , clipY
        , Background.color colourScheme.white
        , Border.color colourScheme.darkBlue
        , Border.width 3
        , htmlAttribute (HA.style "z-index" "10")
        , centerY
        , centerX
        , minimalDropShadow
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color colourScheme.white
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
            ]
            [ viewRecordPreviewTitleBar cfg.language cfg.closeMsg
            , preview
            ]
        ]


viewRecordPreviewTitleBar : Language -> msg -> Element msg
viewRecordPreviewTitleBar language closeMsg =
    row
        [ width fill
        , height (px 30)
        , spacing 10
        , paddingXY 10 0
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color colourScheme.darkBlue
        , Background.color colourScheme.darkBlue
        ]
        [ el
            [ alignLeft
            , centerY
            , onClick closeMsg
            , width (px 18)
            , height (px 18)
            , pointer
            ]
            (closeWindowSvg colourScheme.white)
        , el
            [ alignLeft
            , centerY
            , Font.color colourScheme.white
            , width fill
            ]
            (h4 language localTranslations.recordPreview)
        ]
