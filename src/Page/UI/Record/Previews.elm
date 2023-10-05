module Page.UI.Record.Previews exposing (PreviewConfig, viewPreviewError, viewPreviewRouter)

import Element exposing (Element, alignLeft, alignRight, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, maximum, minimum, moveDown, none, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (h2, h3, h4)
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
    { windowSize : ( Int, Int )
    , closeMsg : msg
    , sourceItemExpandMsg : msg
    , sourceItemsExpanded : Bool
    , incipitInfoSectionsExpanded : Set String
    , incipitInfoToggleMsg : String -> msg
    }


viewPreviewError : Language -> msg -> String -> Element msg
viewPreviewError language closeMsg errMsg =
    row
        [ width fill
        , height fill
        , clipY
        , alignTop
        , alignRight
        , Background.color colourScheme.white
        , Border.color colourScheme.lightBlue
        , Border.width 3
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color colourScheme.white
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
            ]
            [ viewRecordPreviewTitleBar language closeMsg
            , el
                [ centerX
                , centerY
                ]
                (text errMsg)
            ]
        ]


viewPreviewLoading : Language -> Element msg
viewPreviewLoading language =
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
                        (spinnerSvg colourScheme.slateGrey)
                    )
                ]
            ]
        ]


viewPreviewRouter : Language -> PreviewConfig msg -> Maybe ServerData -> Element msg
viewPreviewRouter language cfg previewData =
    let
        ( windowWidth, windowHeight ) =
            cfg.windowSize

        previewHeight =
            round (toFloat windowHeight * 0.6)

        preview =
            case previewData of
                Just (SourceData body) ->
                    viewSourcePreview
                        language
                        cfg.sourceItemsExpanded
                        cfg.sourceItemExpandMsg
                        cfg.incipitInfoSectionsExpanded
                        cfg.incipitInfoToggleMsg
                        body

                Just (PersonData body) ->
                    viewPersonPreview language body

                Just (InstitutionData body) ->
                    viewInstitutionPreview language body

                Just (IncipitData body) ->
                    viewIncipitPreview
                        language
                        cfg.incipitInfoSectionsExpanded
                        cfg.incipitInfoToggleMsg
                        body

                Just (ExternalData body) ->
                    case body.record of
                        ExternalSource sourceBody ->
                            viewExternalSourcePreview language body.project sourceBody

                        ExternalPerson personBody ->
                            viewExternalPersonPreview language body.project personBody

                        ExternalInstitution institutionBody ->
                            viewExternalInstitutionPreview language body.project institutionBody

                Nothing ->
                    viewPreviewLoading language

                _ ->
                    none
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
        , moveDown 100
        , Border.shadow { offset = ( 2, 0 ), size = 2, blur = 5, color = colourScheme.darkGrey }
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color colourScheme.white
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
            ]
            [ viewRecordPreviewTitleBar language cfg.closeMsg
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
