module Page.About.Views exposing (view)

import Config as C
import Element exposing (Element, column, el, fill, height, link, maximum, none, padding, paragraph, row, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Font as Font
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg(..))
import Page.UI.Attributes exposing (headingLG, headingXL, lineSpacing, linkColour, sectionSpacing)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Time exposing (Month(..), Posix)


view : Session -> AboutPageModel -> Element AboutMsg
view _ model =
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
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , Background.color colourScheme.white
            , spacing sectionSpacing
            ]
            [ row
                [ width (fill |> maximum 900) ]
                [ el
                    [ headingXL ]
                    (text "About RISM Online")
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ textColumn
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ paragraph
                        [ width fill ]
                        [ text """The Répertoire International des Sources Musicales (RISM) - International Inventory
                        of Musical Sources - is an international, non-profit organization that aims to comprehensively
                        document extant musical sources worldwide: manuscripts, printed music editions, writings on
                        music theory, and libretti that are found in libraries, archives, churches, schools, and
                        private collections."""
                        ]
                    , paragraph
                        [ width fill ]
                        [ text """RISM Online, a service from """
                        , link [ linkColour ] { label = text "RISM Digital", url = "https://rism.digital" }
                        , text """ provides access to these musical sources through extensive search and browse
                        functions. Multiple entry points, with extensive Source, Person, and Institution search
                        interfaces, provide users with the ability to quickly narrow down relevant results using several
                        different approaches, including keyword searches, filters, and relationship information. """
                        , text """An innovative new Incipit query interface provides fast and accurate notation searches,
                        with coloured notes that highlight the parts of the incipit that matches a query. Users
                        can also narrow down incipits that match by specifying a clef, key signature, or time signature
                         as a filter, or combine a notation search with a keyword search for composer or piece names."""
                        ]
                    , paragraph
                        [ width fill ]
                        [ text """The National Collection search filter lets users narrow down all search functionality
                        to the bibliography of a single country. This automatically narrows down the search capabilities 
                        to just the sources, institutions, and musical incipits available in that country. (Since people 
                        can span multiple countries, they are excluded from the search functions when a National 
                        Collection is active.)""" ]
                    , paragraph
                        [ width fill ]
                        [ text """URLs in RISM Online are guaranteed to be authoritative, stable, and cite-able. You
                        can bookmark, cite, and share URLs among colleagues, with an institutional commitment that they
                        will persist. This includes links to searches and previews, allowing users to share their complex
                        queries with the knowledge that the recipient will see, as close as possible, the same view.""" ]
                    ]
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ el
                    [ headingXL ]
                    (text "Open Data")
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ textColumn
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ paragraph
                        [ width fill ]
                        [ text """All data in RISM Online is available under a Creative Commons CC-BY 3.0 license.
                        You are free to download and modify the data. If you find the data useful, please include a
                        link back to RISM Online. We are also interested in knowing how RISM data
                        is being used, so please get in touch to tell us about your project.""" ]
                    ]
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ el
                    [ headingXL ]
                    (text "Contact")
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ textColumn
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ paragraph
                        [ width fill ]
                        [ text """We are constantly improving RISM Online. Feedback about your experience is welcome!
                        Let us know if you could not find what you were looking for, or if there is some information
                        incorrect or missing.""" ]
                    , paragraph
                        [ width fill ]
                        [ text "General feedback can be sent to "
                        , link [ linkColour ] { label = text "feedback@rism.online. ", url = "mailto:feedback@rism.online" }
                        ]
                    , paragraph
                        []
                        [ text """All records also feature a "Report an issue" link at the bottom of the page, which
                         takes you to a form where you can describe the problem. Whenever possible it is helpful to
                         include a link to the record or search that triggered the problem so that we can reproduce it.
                         The URL of the current page is automatically added to the feedback form submission."""
                        ]
                    ]
                ]
            , row
                [ width fill ]
                [ el
                    [ headingXL ]
                    (text "Viewing options")
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ textColumn
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ paragraph
                        [ width fill ]
                        [ text """Activating this control will put links to the Muscat records in the footer
                            of every record. Note that you will still need permissions to log in and edit the
                            records in Muscat. """ ]
                    , paragraph
                        [ width fill
                        , Font.bold
                        ]
                        [ text "Please refresh your browser after activating." ]
                    , paragraph
                        [ width fill ]
                        [ el
                            []
                            (Toggle.view isActive UserToggledEnableMuscatLinks
                                |> Toggle.setLabel "Enable Muscat Links"
                                |> Toggle.render
                            )
                        ]
                    ]
                ]
            , row
                [ width fill ]
                [ el
                    [ headingXL ]
                    (text "Credits and Licenses")
                ]
            , row
                [ width fill ]
                [ el
                    [ headingLG ]
                    (text "Background Images")
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ textColumn
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ paragraph
                        [ width fill ]
                        [ el [ Font.semiBold ] (text "Sources: ")
                        , text "Luzzaschi, Luzzasco. 1601. "
                        , el [ Font.italic ] (text "Madrigali di Luzzasco Luzzaschi per cantare, et sonare a vno, e doi, e tre soprani")
                        , text ". Rome: Simone Verovio. p. 5. "
                        , link [ linkColour ]
                            { label = text "Library of Congress, Music Division, Washington, DC."
                            , url = "https://www.loc.gov/resource/ihas.200154752.0/?sp=15&st=image"
                            }
                        ]
                    , paragraph
                        [ width fill ]
                        [ el [ Font.semiBold ] (text "People: ")
                        , text "Coques, Gonzales. ca. 1653. "
                        , el [ Font.italic ] (text "Jacques van Eyck and His Family (?) ")
                        , text "Museum of Fine Arts, Budapest. "
                        , link [ linkColour ]
                            { label = text "Wikimedia Commons."
                            , url = "https://commons.wikimedia.org/wiki/File:Gonzales_Coques_-_Portrait_of_the_Duarte_family.jpg"
                            }
                        ]
                    , paragraph
                        [ width fill ]
                        [ el [ Font.semiBold ] (text "Institutions: ")
                        , text """Iliff, David. 2015. The interior of Duke Humphrey's Library, the oldest
                        reading room of the Bodleian Library in the University of Oxford. License: CC BY-SA 3.0. """
                        , link [ linkColour ]
                            { label = text "Wikimedia Commons."
                            , url = "https://en.wikipedia.org/wiki/File:Duke_Humfrey%27s_Library_Interior_5,_Bodleian_Library,_Oxford,_UK_-_Diliff.jpg"
                            }
                        ]
                    , paragraph
                        [ width fill ]
                        [ el [ Font.semiBold ] (text "Incipits: ")
                        , text "Sarasin, Lukas. [1760–1802]. "
                        , el [ Font.italic ] (text "Katalog der Lucas Sarasin'schen Musiksammlung. ")
                        , text "Universitätsbibliothek Basel, HKun d III 9. Public Domain. "
                        , link [ linkColour ]
                            { label = text "e-Manuscripta."
                            , url = "https://doi.org/10.7891/e-manuscripta-13836"
                            }
                        ]
                    ]
                ]
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
