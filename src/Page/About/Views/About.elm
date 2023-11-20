module Page.About.Views.About exposing (view)

import Config as C
import Element exposing (Element, clipY, column, el, fill, height, maximum, none, padding, paragraph, row, scrollbarY, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Font as Font
import Language exposing (Language(..), LanguageMap, LanguageValue(..), toLanguageMapWithLanguage)
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg(..))
import Page.UI.Attributes exposing (headingXL, lineSpacing, sectionSpacing)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Markdown as Markdown
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Time exposing (Month(..), Posix)


aboutTextEnglish : String
aboutTextEnglish =
    """# About RISM Online

The Répertoire International des Sources Musicales (RISM) - International Inventory
of Musical Sources - is an international, non-profit organization that aims to comprehensively
document extant musical sources worldwide: manuscripts, printed music editions, writings on
music theory, and libretti that are found in libraries, archives, churches, schools, and
private collections.

RISM Online, a service from [the RISM Digital Center](https://rism.digital)
provides access to these musical sources through extensive search and browse
functions. Multiple entry points, with extensive Source, Person, and Institution search
interfaces, provide users with the ability to quickly narrow down relevant results using several
different approaches, including keyword searches, filters, and relationship information.

The Incipit query interface provides fast and accurate notation searches,
with coloured notes that highlight the parts of the incipit that matches a query. Users
can also narrow down incipits that match by specifying a clef, key signature, or time signature
as a filter, or combine a notation search with a keyword search for composer or piece names.

The National Collection search filter lets users narrow down all search functionality
to the bibliography of a single country. This automatically narrows down the search capabilities
to just the sources, institutions, and musical incipits available in that country. (Since people
can span multiple countries, they are excluded from the search functions when a National
Collection is active.)

URLs in RISM Online are guaranteed to be authoritative, stable, and cite-able. You
can bookmark, cite, and share URLs among colleagues, with an institutional commitment that they
will persist. This includes links to searches and previews, allowing users to share their complex
queries with the knowledge that the recipient will see, as close as possible, the same view.

## Open Data

All data in RISM Online is available under a Creative Commons CC-BY 3.0 license.
You are free to download and modify the data. If you find the data useful, please include a
link back to RISM Online. We are also interested in knowing how RISM data
is being used, so please get in touch to tell us about your project.

## Contact

We are constantly improving RISM Online. Feedback about your experience is welcome!
Let us know if you could not find what you were looking for, or if there is some information
incorrect or missing.

General feedback can be sent to [feedback@rism.online](mailto:feedback@rism.online).

All records also feature a "Report an issue" link at the bottom of the page, which
takes you to a form where you can describe the problem. Whenever possible it is helpful to
include a link to the record or search that triggered the problem so that we can reproduce it.
The URL of the current page is automatically added to the feedback form submission.

## Credits and licenses

### Background images

**Sources**: Luzzaschi, Luzzasco. 1601. __Madrigali di Luzzasco Luzzaschi per cantare, et sonare a vno, e doi, e tre soprani.__ Rome: Simone Verovio. p. 5.
[Library of Congress, Music Division, Washington, DC.](https://www.loc.gov/resource/ihas.200154752.0/?sp=15&st=image)

**People**: Coques, Gonzales. ca. 1653. __Jacques van Eyck and His Family (?),__ Museum of Fine Arts, Budapest.
[Wikimedia Commons.](https://commons.wikimedia.org/wiki/File:Gonzales_Coques_-_Portrait_of_the_Duarte_family.jpg)

**Institutions**: Iliff, David. 2015. The interior of Duke Humphrey's Library, the oldest reading room of the Bodleian Library in the University of Oxford. License: CC BY-SA 3.0.
[Wikimedia Commons.](https://en.wikipedia.org/wiki/File:Duke_Humfrey%27s_Library_Interior_5,_Bodleian_Library,_Oxford,_UK_-_Diliff.jpg)

**Incipits**: Sarasin, Lukas. [1760–1802]. __Katalog der Lucas Sarasin'schen Musiksammlung.__ Universitätsbibliothek Basel, HKun d III 9. Public Domain.
[e-Manuscripta.](https://doi.org/10.7891/e-manuscripta-13836)
"""


aboutText : LanguageMap
aboutText =
    [ LanguageValue English [ aboutTextEnglish ] ]


view : Session -> AboutPageModel -> Element AboutMsg
view session model =
    let
        isActive =
            model.linksEnabled

        indexedTimestamp =
            case model.response of
                Response (AboutData body) ->
                    viewLastIndexed body.lastIndexed

                _ ->
                    none

        indexerVersion =
            case model.response of
                Response (AboutData body) ->
                    text ("Indexer Version: " ++ body.indexerVersion)

                _ ->
                    none

        serverVersion =
            case model.response of
                Response (AboutData body) ->
                    text ("Server Version: " ++ body.serverVersion)

                _ ->
                    none

        renderedAboutText =
            Markdown.view session.language aboutText
    in
    row
        [ width fill
        , height fill
        , clipY
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , Background.color colourScheme.white
            , spacing sectionSpacing
            , scrollbarY
            ]
            [ row
                [ width (fill |> maximum 900)
                , Font.size 16
                ]
                [ renderedAboutText ]
            , row
                [ width (fill |> maximum 900) ]
                [ el
                    [ headingXL ]
                    (text "Current version")
                ]
            , row
                [ width fill ]
                [ column
                    [ spacing lineSpacing ]
                    [ text ("UI Version: " ++ C.uiVersion)
                    , serverVersion
                    , indexerVersion
                    , indexedTimestamp
                    ]
                ]
            ]
        ]


viewLastIndexed : Posix -> Element msg
viewLastIndexed timestamp =
    let
        day =
            Time.toDay Time.utc timestamp
                |> String.fromInt
                |> String.padLeft 2 '0'

        hour =
            Time.toHour Time.utc timestamp
                |> String.fromInt
                |> String.padLeft 2 '0'

        minute =
            Time.toMinute Time.utc timestamp
                |> String.fromInt
                |> String.padLeft 2 '0'

        month =
            case Time.toMonth Time.utc timestamp of
                Jan ->
                    "01"

                Feb ->
                    "02"

                Mar ->
                    "03"

                Apr ->
                    "04"

                May ->
                    "05"

                Jun ->
                    "06"

                Jul ->
                    "07"

                Aug ->
                    "08"

                Sep ->
                    "09"

                Oct ->
                    "10"

                Nov ->
                    "11"

                Dec ->
                    "12"

        year =
            String.fromInt (Time.toYear Time.utc timestamp)
    in
    text ("Last indexed: " ++ year ++ "-" ++ month ++ "-" ++ day ++ " " ++ hour ++ ":" ++ minute)
