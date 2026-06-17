module Page.UI.Record.Previews exposing (PreviewConfig, viewMobilePreviewForResponse, viewPreviewError, viewPreviewRouter)

import Element exposing (Element, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, maximum, minimum, moveDown, moveRight, none, padding, paddingXY, paragraph, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Html.Attributes as HA
import Language exposing (Language, LanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Error.Views exposing (errorMessageView)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..))
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Animations exposing (PreviewAnimationStatus(..), animatedLoader, animatedRow)
import Page.UI.Attributes exposing (emptyAttribute, minimalDropShadow, sectionSpacing, sidebarWidth)
import Page.UI.Components exposing (viewMobileWindowTitleBar, viewWindowShell)
import Page.UI.Errors exposing (ErrorResponse)
import Page.UI.Events exposing (onComplete)
import Page.UI.Images exposing (spinnerSvg)
import Page.UI.Layout as Layout
import Page.UI.Record.Previews.ExternalInstitution exposing (viewExternalInstitutionPreview)
import Page.UI.Record.Previews.ExternalPerson exposing (viewExternalPersonPreview)
import Page.UI.Record.Previews.ExternalSource exposing (viewExternalSourcePreview)
import Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)
import Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)
import Page.UI.Record.Previews.Person exposing (viewPersonPreview)
import Page.UI.Record.Previews.Source exposing (viewSourcePreview)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
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
    , summaryFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    }


viewPreviewError :
    { closeMsg : msg
    , errorMessage : ErrorResponse
    , language : Language
    , windowSize : ( Int, Int )
    }
    -> Element msg
viewPreviewError cfg =
    let
        messageDetails =
            errorMessageView cfg.language cfg.errorMessage

        ( _, windowHeight ) =
            cfg.windowSize

        previewHeight =
            round (toFloat windowHeight * 0.6)
    in
    viewWindowShell
        { body =
            row
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
                    [ messageDetails
                    ]
                ]
        , closeMsg = cfg.closeMsg
        , containerAttributes =
            [ width (fill |> minimum 320 |> maximum 800)
            , height (fill |> maximum previewHeight)
            , clipY
            ]
        , language = cfg.language
        , title = localTranslations.recordPreview
        }


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


choosePreview : PreviewConfig msg -> Maybe ServerData -> Element msg
choosePreview cfg previewData =
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
                , paragraphFormatter = cfg.paragraphFormatter
                , preRenderedFormatter = cfg.preRenderedFormatter
                , relationshipFormatter = cfg.relationshipFormatter
                , summaryFormatter = cfg.summaryFormatter
                }
                body

        Just (PersonData body) ->
            viewPersonPreview
                { language = cfg.language
                , paragraphFormatter = cfg.paragraphFormatter
                , relationshipFormatter = cfg.relationshipFormatter
                , summaryFormatter = cfg.summaryFormatter
                }
                body

        Just (InstitutionData body) ->
            viewInstitutionPreview
                { language = cfg.language
                , paragraphFormatter = cfg.paragraphFormatter
                , relationshipFormatter = cfg.relationshipFormatter
                , summaryFormatter = cfg.summaryFormatter
                , window = cfg.windowSize
                }
                body

        Just (IncipitData body) ->
            viewIncipitPreview
                { incipitInfoExpanded = cfg.incipitInfoSectionsExpanded
                , infoToggleMsg = cfg.incipitInfoToggleMsg
                , language = cfg.language
                , summaryFormatter = cfg.summaryFormatter
                }
                body

        Just (ExternalData body) ->
            case body.record of
                ExternalSource sourceBody ->
                    viewExternalSourcePreview
                        { language = cfg.language
                        , paragraphFormatter = cfg.paragraphFormatter
                        , preRenderedFormatter = cfg.preRenderedFormatter
                        , summaryFormatter = cfg.summaryFormatter
                        }
                        body.project
                        sourceBody

                ExternalPerson personBody ->
                    viewExternalPersonPreview
                        { language = cfg.language
                        , summaryFormatter = cfg.summaryFormatter
                        }
                        body.project
                        personBody

                ExternalInstitution institutionBody ->
                    viewExternalInstitutionPreview
                        { language = cfg.language
                        , summaryFormatter = cfg.summaryFormatter
                        }
                        body.project
                        institutionBody

        Nothing ->
            viewPreviewLoading

        _ ->
            none


viewPreviewRouter : PreviewConfig msg -> Maybe ServerData -> Element msg
viewPreviewRouter cfg previewData =
    let
        ( windowWidth, windowHeight ) =
            cfg.windowSize

        previewHeight =
            round (toFloat windowHeight * 0.75)

        previewWidth =
            Layout.previewWidth windowWidth sidebarWidth

        moveDownAmount =
            (toFloat windowHeight * 0.01)
                |> clamp 10 20

        availableRight =
            Layout.previewAvailableRightWidth windowWidth sidebarWidth

        moveRightAmount =
            (toFloat availableRight * 0.02)
                |> clamp 12 32

        preview =
            choosePreview cfg previewData
    in
    viewWindowShell
        { body = preview
        , closeMsg = cfg.closeMsg
        , containerAttributes =
            [ width (px previewWidth)
            , height (fill |> maximum previewHeight)
            , moveDown moveDownAmount
            , moveRight moveRightAmount
            , clipY
            ]
        , language = cfg.language
        , title = localTranslations.recordPreview
        }


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
            choosePreview cfg previewData
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


viewMobilePreviewForResponse : PreviewConfig msg -> Response ServerData -> Element msg
viewMobilePreviewForResponse cfg response =
    case response of
        Loading oldData ->
            viewMobilePreviewRouter cfg oldData

        Response resp ->
            viewMobilePreviewRouter cfg (Just resp)

        _ ->
            none
