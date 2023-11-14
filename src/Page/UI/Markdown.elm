module Page.UI.Markdown exposing (renderer, view)

import Element exposing (Attribute, Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Input
import Element.Region
import Html
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Markdown.Block as Block exposing (ListItem(..), Task(..))
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Page.UI.Attributes exposing (bodyMonospaceFont)
import Page.UI.Style exposing (colourScheme)



-- From: https://github.com/dillonkearns/elm-markdown/blob/master/examples/src/ElmUi.elm


view : Language -> LanguageMap -> Element msg
view language markdown =
    case
        markdown
            |> extractLabelFromLanguageMap language
            |> Markdown.Parser.parse
            |> Result.mapError (\error -> error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")
            |> Result.andThen (Markdown.Renderer.render renderer)
    of
        Ok rendered ->
            Element.textColumn
                [ Element.width Element.fill
                , Element.spacing 10
                ]
                rendered

        Err errors ->
            Element.textColumn
                [ Element.width Element.fill ]
                [ Element.text errors ]


renderer : Markdown.Renderer.Renderer (Element msg)
renderer =
    { heading = heading
    , paragraph =
        Element.paragraph
            [ Element.width Element.fill
            ]
    , blockQuote =
        \children ->
            Element.paragraph
                [ Element.Border.widthEach { bottom = 0, left = 10, right = 0, top = 0 }
                , Element.padding 10
                , Element.Border.color colourScheme.lightGrey
                , Element.Background.color colourScheme.white
                ]
                children
    , html = Markdown.Html.oneOf []
    , text = Element.text
    , codeSpan = code
    , strong = \content -> Element.paragraph [ Font.bold ] content
    , emphasis = \content -> Element.paragraph [ Font.italic ] content
    , strikethrough = \content -> Element.paragraph [ Font.strike ] content
    , hardLineBreak = Html.br [] [] |> Element.html
    , link =
        \{ title, destination } body ->
            Element.newTabLink []
                { label =
                    Element.paragraph
                        [ Font.color colourScheme.lightBlue
                        , Element.htmlAttribute (HA.style "overflow-wrap" "break-word")
                        , Element.htmlAttribute (HA.style "word-break" "break-word")
                        ]
                        body
                , url = destination
                }
    , image =
        \image ->
            Element.image
                [ Element.width Element.fill ]
                { description = image.alt
                , src = image.src
                }
    , unorderedList =
        \items ->
            Element.column [ Element.paddingXY 10 0 ]
                (items
                    |> List.map
                        (\(ListItem task children) ->
                            Element.paragraph
                                []
                                [ Element.row
                                    [ Element.alignTop ]
                                    ((case task of
                                        NoTask ->
                                            Element.text "•"

                                        IncompleteTask ->
                                            Element.Input.defaultCheckbox False

                                        CompletedTask ->
                                            Element.Input.defaultCheckbox True
                                     )
                                        :: Element.text " "
                                        :: children
                                    )
                                ]
                        )
                )
    , orderedList =
        \startingIndex items ->
            Element.column
                [ Element.spacing 15 ]
                (List.indexedMap
                    (\index itemBlocks ->
                        Element.paragraph
                            [ Element.spacing 5 ]
                            [ Element.paragraph
                                [ Element.alignTop ]
                                (Element.text
                                    (String.fromInt (index + startingIndex) ++ " ")
                                    :: itemBlocks
                                )
                            ]
                    )
                    items
                )
    , codeBlock = codeBlock
    , thematicBreak = Element.none
    , table = Element.column []
    , tableHeader =
        Element.column
            [ Font.bold
            , Element.width Element.fill
            , Font.center
            ]
    , tableBody = Element.column []
    , tableRow =
        Element.row
            [ Element.height Element.fill
            , Element.width Element.fill
            ]
    , tableCell =
        \maybeAlignment children ->
            Element.paragraph
                tableBorder
                children
    , tableHeaderCell =
        \maybeAlignment children ->
            Element.paragraph
                tableBorder
                children
    }


tableBorder : List (Attribute msg)
tableBorder =
    [ Element.Border.color colourScheme.midGrey
    , Element.Border.width 1
    , Element.Border.solid
    , Element.paddingXY 6 13
    , Element.height Element.fill
    ]


rawTextToId : String -> String
rawTextToId rawText =
    rawText
        |> String.split " "
        |> String.join "-"
        |> String.toLower


heading :
    { children : List (Element msg)
    , level : Block.HeadingLevel
    , rawText : String
    }
    -> Element msg
heading { children, level, rawText } =
    Element.paragraph
        [ Font.size
            (case level of
                Block.H1 ->
                    36

                Block.H2 ->
                    24

                _ ->
                    20
            )
        , Font.medium
        , Element.Region.heading (Block.headingLevelToInt level)
        , Element.htmlAttribute
            (HA.attribute "name" (rawTextToId rawText))
        , Element.htmlAttribute
            (HA.id (rawTextToId rawText))
        ]
        children


code : String -> Element msg
code snippet =
    Element.el
        [ Element.Background.color
            (Element.rgba 0 0 0 0.04)
        , Element.Border.rounded 2
        , Element.paddingXY 5 3
        , bodyMonospaceFont
        ]
        (Element.text snippet)


codeBlock : { body : String, language : Maybe String } -> Element msg
codeBlock details =
    Element.paragraph
        [ Element.Background.color (Element.rgba 0 0 0 0.03)
        , Element.htmlAttribute (HA.style "white-space" "pre")
        , Element.htmlAttribute (HA.style "overflow-wrap" "break-word")
        , Element.htmlAttribute (HA.style "word-break" "break-word")
        , Element.padding 20
        , bodyMonospaceFont
        ]
        [ Element.text details.body ]
