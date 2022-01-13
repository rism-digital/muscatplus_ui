module Page.Record.Views.SourcePage.TableOfContents exposing (..)

import Element exposing (Element, alignRight, column, el, fill, htmlAttribute, moveDown, moveLeft, padding, px, row, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HTA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.TablesOfContents exposing (createSectionLink, createTocLink)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


createSourceRecordToc : Language -> FullSourceBody -> Element RecordMsg
createSourceRecordToc language body =
    el
        [ Border.width 1
        , alignRight
        , moveDown 100
        , moveLeft 100
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , htmlAttribute (HTA.style "z-index" "10")
        ]
        (row
            [ width (px 300)
            , padding 10
            ]
            [ column
                [ width fill
                , spacing 5
                ]
                [ createTocLink language localTranslations.recordTop (UserClickedToCItem body.sectionToc)
                , viewMaybe (createSectionLink language) body.contents
                , viewMaybe (createSectionLink language) body.exemplars
                , viewMaybe (createSectionLink language) body.incipits
                , viewMaybe (createSectionLink language) body.materialGroups
                , viewMaybe (createSectionLink language) body.relationships
                , viewMaybe (createSectionLink language) body.referencesNotes
                , viewMaybe (createSectionLink language) body.items
                ]
            ]
        )
