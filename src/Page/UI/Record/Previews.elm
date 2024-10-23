module Page.UI.Record.Previews exposing (PreviewConfig, viewMobilePreviewRouter, viewPreviewError, viewPreviewRouter)

import Element exposing (Element, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, maximum, minimum, moveDown, moveRight, none, padding, paddingXY, paragraph, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Http.Detailed
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..))
import Page.UI.Animations exposing (PreviewAnimationStatus(..), animatedLoader, animatedRow)
import Page.UI.Attributes exposing (emptyAttribute, minimalDropShadow, resultsColumnWidth, sectionSpacing, sidebarWidth)
import Page.UI.Components exposing (viewMobileWindowTitleBar, viewWindowTitleBar)
import Page.UI.Errors exposing (createErrorMessage)
import Page.UI.Events exposing (onComplete)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Record.Previews.ExternalInstitution exposing (viewExternalInstitutionPreview)
import Page.UI.Record.Previews.ExternalPerson exposing (viewExternalPersonPreview)
import Page.UI.Record.Previews.ExternalSource exposing (viewExternalSourcePreview)
import Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)
import Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)
import Page.UI.Record.Previews.Person exposing (viewPersonPreview)
import Page.UI.Record.Previews.Source exposing (viewMobileSourcePreview, viewSourcePreview)
import Page.UI.Style exposing (colourScheme)
import Response exposing (ServerData(..))
import Set exposing (Set)
import Simple.Animation as Animation
import Simple.Animation.Property as P


type alias PreviewConfig msg =
    { language : Language
    , windowSize : ( Int, Int )
    , closeMsg : msg
    , hideAnimationStartedMsg : msg
    , showAnimationFinishedMsg : msg
    , animationStatus : PreviewAnimationStatus
    , sourceItemExpandMsg : msg
    , sourceItemsExpanded : Bool
    , incipitInfoSectionsExpanded : Set String
    , incipitInfoToggleMsg : String -> msg
    , expandedDigitizedCopiesMsg : msg
    , expandedDigitizedCopiesCallout : Bool
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
        ( mainMessage, details ) =
            createErrorMessage cfg.language cfg.errorMessage

        messageDetails =
            Maybe.withDefault "" details

        ( _, windowHeight ) =
            cfg.windowSize

        previewHeight =
            round (toFloat windowHeight * 0.6)
    in
    row
        [ width (fill |> minimum 600 |> maximum 800)
        , height (fill |> maximum previewHeight)
        , clipY
        , Background.color colourScheme.white
        , Border.color colourScheme.darkBlue
        , Border.width 3
        , htmlAttribute (HA.style "z-index" "10")
        , minimalDropShadow
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color colourScheme.white
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
            ]
            [ viewWindowTitleBar cfg.language localTranslations.recordPreview cfg.closeMsg
            , row
                [ width fill
                , height fill
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
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

        moveDownAmount =
            (toFloat windowHeight * 0.01)
                |> clamp 10 20

        moveRightAmount =
            (toFloat (windowWidth - (sidebarWidth + resultsColumnWidth)) * 0.02)
                |> clamp 20 40

        preview =
            case previewData of
                Just (SourceData body) ->
                    viewSourcePreview
                        { expandMsg = cfg.sourceItemExpandMsg
                        , expandedDigitizedCopiesCallout = cfg.expandedDigitizedCopiesCallout
                        , expandedDigitizedCopiesMsg = cfg.expandedDigitizedCopiesMsg
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
        [ width (px previewWidth |> minimum 800 |> maximum 1100)
        , height (fill |> maximum previewHeight)
        , moveDown moveDownAmount
        , moveRight moveRightAmount
        , clipY
        , Background.color colourScheme.white
        , Border.color colourScheme.darkBlue
        , Border.width 3
        , htmlAttribute (HA.style "z-index" "10")
        , minimalDropShadow
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color colourScheme.white
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
            ]
            [ viewWindowTitleBar cfg.language localTranslations.recordPreview cfg.closeMsg
            , preview
            ]
        ]


viewMobilePreviewRouter : PreviewConfig msg -> Maybe ServerData -> Element msg
viewMobilePreviewRouter cfg previewData =
    let
        windowWidth =
            cfg.windowSize
                |> Tuple.first
                |> toFloat

        previewAnimation =
            case cfg.animationStatus of
                MovingIn ->
                    Animation.fromTo
                        { duration = 200
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.x windowWidth ]
                        [ P.x 0 ]

                MovingOut ->
                    Animation.fromTo
                        { duration = 200
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.x 0 ]
                        [ P.x windowWidth ]

                ShownAndNotMoving ->
                    Animation.fromTo
                        { duration = 0
                        , options = []
                        }
                        [ P.x windowWidth ]
                        [ P.x windowWidth ]

                NoAnimation ->
                    Animation.empty

        onCompleteMsg =
            case cfg.animationStatus of
                MovingIn ->
                    onComplete cfg.showAnimationFinishedMsg

                MovingOut ->
                    onComplete cfg.closeMsg

                ShownAndNotMoving ->
                    emptyAttribute

                NoAnimation ->
                    emptyAttribute

        preview =
            case previewData of
                Just (SourceData sourceBody) ->
                    viewMobileSourcePreview
                        { expandMsg = cfg.sourceItemExpandMsg
                        , expandedDigitizedCopiesCallout = cfg.expandedDigitizedCopiesCallout
                        , expandedDigitizedCopiesMsg = cfg.expandedDigitizedCopiesMsg
                        , incipitInfoExpanded = cfg.incipitInfoSectionsExpanded
                        , incipitInfoToggleMsg = cfg.incipitInfoToggleMsg
                        , itemsExpanded = cfg.sourceItemsExpanded
                        , language = cfg.language
                        }
                        sourceBody

                Just (PersonData _) ->
                    none

                Just (InstitutionData _) ->
                    none

                Just (IncipitData _) ->
                    none

                Just (ExternalData body) ->
                    case body.record of
                        ExternalSource _ ->
                            none

                        ExternalPerson _ ->
                            none

                        ExternalInstitution _ ->
                            none

                Nothing ->
                    none

                _ ->
                    none
    in
    animatedRow
        previewAnimation
        [ width (fill |> maximum (Tuple.first cfg.windowSize))
        , height fill
        , Background.color colourScheme.white
        , htmlAttribute (HA.style "z-index" "10")
        , minimalDropShadow
        , onCompleteMsg
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Background.color colourScheme.white
            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
            ]
            [ viewMobileWindowTitleBar cfg.language cfg.hideAnimationStartedMsg
            , preview
            ]
        ]
