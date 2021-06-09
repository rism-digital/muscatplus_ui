module Page.RecordTypes.Relationship exposing (..)

import Dict
import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias RelationshipsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List RelationshipBody
    }


type alias RelationshipBody =
    { label : LanguageMap
    , role : RelationshipRole
    , qualifier : Maybe RelationshipQualifier
    , qualifierLabel : Maybe LanguageMap
    , relatedTo : Maybe RelatedToBody
    , name : Maybe LanguageMap
    }


type alias RelatedToBody =
    { id : String
    , label : LanguageMap
    , type_ : RelatedTo
    }


type RelatedTo
    = PersonRelationship
    | InstitutionRelationship
    | PlaceRelationship
    | UnknownRelationship


type RelationshipQualifier
    = AscertainedQualifier
    | VerifiedQualifier
    | ConjecturalQualifier
    | AllegedQualifier
    | DoubtfulQualifier
    | MisattributedQualifier
    | UnknownQualifier


{-|

    Maps the expected value in the 'qualifier' section
    to a type-defined value.

-}
qualifierMap : List ( String, RelationshipQualifier )
qualifierMap =
    [ ( "rism:Ascertained", AscertainedQualifier )
    , ( "rism:Verified", VerifiedQualifier )
    , ( "rism:Conjectural", ConjecturalQualifier )
    , ( "rism:Alleged", AllegedQualifier )
    , ( "rism:Doubtful", DoubtfulQualifier )
    , ( "rism:Misattributed", MisattributedQualifier )
    ]


qualifierConverter : String -> Decoder RelationshipQualifier
qualifierConverter qualString =
    -- if we can't find the value in the dictionary,
    -- then assume it's unknown.
    Dict.fromList qualifierMap
        |> Dict.get qualString
        |> Maybe.withDefault UnknownQualifier
        |> Decode.succeed


type RelationshipRole
    = ArrangerRole
    | AssigneeRole
    | AssociatedNameRole
    | AuthorRole
    | BooksellerRole
    | ConceptorRole
    | ComposerRole
    | CensorRole
    | CopyrightHolderRole
    | ComposerAuthorRole
    | ContributorRole
    | DepositorRole
    | DistributorRole
    | DedicateeRole
    | EditorRole
    | EngraverRole
    | EventPlaceRole
    | FormerOwnerRole
    | IllustratorRole
    | LibrettistRole
    | LicenseeRole
    | LithographerRole
    | LyricistRole
    | OtherRole
    | PublisherRole
    | PapermakerRole
    | PerformerRole
    | PrinterRole
    | CopyistRole
    | TranslatorRole
    | TypeDesignerRole
    | BrotherOfRole
    | ChildOfRole
    | ConfusedWithRole
    | FatherOfRole
    | MarriedToRole
    | MotherOfRole
    | RelatedToRole
    | SisterOfRole
    | UnknownRole


{-|

    Maps the expected values of the 'role' in the JSON response to
    a type-defined value.

-}
roleMap : List ( String, RelationshipRole )
roleMap =
    [ ( "rism:arr", ArrangerRole )
    , ( "rism:asg", AssigneeRole )
    , ( "rism:asn", AssociatedNameRole )
    , ( "rism:aut", AuthorRole )
    , ( "rism:bsl", BooksellerRole )
    , ( "rism:ccp", ConceptorRole )
    , ( "rism:cmp", ComposerRole )
    , ( "rism:cns", CensorRole )
    , ( "rism:cph", CopyrightHolderRole )
    , ( "rism:cre", ComposerAuthorRole )
    , ( "rism:ctb", ContributorRole )
    , ( "rism:dpt", DepositorRole )
    , ( "rism:dst", DistributorRole )
    , ( "rism:dte", DedicateeRole )
    , ( "rism:edt", EditorRole )
    , ( "rism:egr", EngraverRole )
    , ( "rism:evp", EventPlaceRole )
    , ( "rism:fmo", FormerOwnerRole )
    , ( "rism:ill", IllustratorRole )
    , ( "rism:lbt", LibrettistRole )
    , ( "rism:lse", LicenseeRole )
    , ( "rism:ltg", LithographerRole )
    , ( "rism:lyr", LyricistRole )
    , ( "rism:oth", OtherRole )
    , ( "rism:pbl", PublisherRole )
    , ( "rism:ppm", PapermakerRole )
    , ( "rism:prf", PerformerRole )
    , ( "rism:prt", PrinterRole )
    , ( "rism:scr", CopyistRole )
    , ( "rism:trl", TranslatorRole )
    , ( "rism:tyd", TypeDesignerRole )
    , ( "rism:brother_of", BrotherOfRole )
    , ( "rism:child_of", ChildOfRole )
    , ( "rism:confused_with", ConfusedWithRole )
    , ( "rism:father_of", FatherOfRole )
    , ( "rism:married_to", MarriedToRole )
    , ( "rism:mother_of", MotherOfRole )
    , ( "rism:other", OtherRole )
    , ( "rism:related_to", RelatedToRole )
    , ( "rism:sister_of", SisterOfRole )
    ]


roleConverter : String -> Decoder RelationshipRole
roleConverter roleString =
    Dict.fromList roleMap
        |> Dict.get roleString
        |> Maybe.withDefault UnknownRole
        |> Decode.succeed


relatedToTypeDecoder : Decoder RelatedTo
relatedToTypeDecoder =
    Decode.string
        |> andThen relatedToConverter


roleDecoder : Decoder RelationshipRole
roleDecoder =
    Decode.string
        |> andThen roleConverter


qualifierDecoder : Decoder RelationshipQualifier
qualifierDecoder =
    Decode.string
        |> andThen qualifierConverter


relatedToBodyDecoder : Decoder RelatedToBody
relatedToBodyDecoder =
    Decode.succeed RelatedToBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "type" relatedToTypeDecoder


relatedToConverter : String -> Decoder RelatedTo
relatedToConverter typeString =
    case typeString of
        "rism:Person" ->
            Decode.succeed PersonRelationship

        "rism:Institution" ->
            Decode.succeed InstitutionRelationship

        "rism:Place" ->
            Decode.succeed PlaceRelationship

        _ ->
            Decode.succeed UnknownRelationship


relationshipsSectionBodyDecoder : Decoder RelationshipsSectionBody
relationshipsSectionBodyDecoder =
    Decode.succeed RelationshipsSectionBody
        |> hardcoded "record-relationships-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list relationshipBodyDecoder)


relationshipBodyDecoder : Decoder RelationshipBody
relationshipBodyDecoder =
    Decode.succeed RelationshipBody
        |> required "label" languageMapLabelDecoder
        |> optional "role" roleDecoder UnknownRole
        |> optional "qualifier" (Decode.maybe qualifierDecoder) Nothing
        |> optional "qualifierLabel" (Decode.maybe languageMapLabelDecoder) Nothing
        |> optional "relatedTo" (Decode.maybe relatedToBodyDecoder) Nothing
        |> optional "name" (Decode.maybe languageMapLabelDecoder) Nothing
