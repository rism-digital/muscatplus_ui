module Page.RecordTypes.Relationship exposing
    ( QualifierBody
    , RelatedTo(..)
    , RelatedToBody
    , RelationshipBody
    , RelationshipQualifier(..)
    , RelationshipRole(..)
    , RelationshipsSectionBody
    , RoleBody
    , qualifierBodyDecoder
    , relatedToBodyDecoder
    , relationshipBodyDecoder
    , relationshipsSectionBodyDecoder
    , roleBodyDecoder
    )

import Dict
import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)



{-
   Handles person, place, and institution
   relationships to various other types of records.

-}


type alias QualifierBody =
    { label : LanguageMap
    , value : String
    , type_ : RelationshipQualifier
    }


type RelatedTo
    = PersonRelationship
    | InstitutionRelationship
    | PlaceRelationship
    | SourceRelationship
    | UnknownRelationship


type alias RelatedToBody =
    { id : String
    , label : LanguageMap
    , type_ : RelatedTo
    }


type alias RelationshipBody =
    { role : Maybe RoleBody
    , qualifier : Maybe QualifierBody
    , relatedTo : Maybe RelatedToBody
    , name : Maybe LanguageMap
    , note : Maybe LanguageMap
    }


type RelationshipQualifier
    = AscertainedQualifier
    | VerifiedQualifier
    | ConjecturalQualifier
    | AllegedQualifier
    | DoubtfulQualifier
    | MisattributedQualifier
    | UnknownQualifier


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


type alias RelationshipsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List RelationshipBody
    }


type alias RoleBody =
    { label : LanguageMap
    , value : String
    , type_ : RelationshipRole
    }


qualifierBodyDecoder : Decoder QualifierBody
qualifierBodyDecoder =
    Decode.succeed QualifierBody
        |> required "label" languageMapLabelDecoder
        |> required "value" string
        |> optional "id" qualifierDecoder UnknownQualifier


qualifierConverter : String -> Decoder RelationshipQualifier
qualifierConverter qualString =
    -- if we can't find the value in the dictionary,
    -- then assume it's unknown.
    Dict.fromList qualifierMap
        |> Dict.get qualString
        |> Maybe.withDefault UnknownQualifier
        |> Decode.succeed


qualifierDecoder : Decoder RelationshipQualifier
qualifierDecoder =
    string
        |> andThen qualifierConverter


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


relatedToBodyDecoder : Decoder RelatedToBody
relatedToBodyDecoder =
    Decode.succeed RelatedToBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "type" relatedToTypeDecoder


relatedToConverter : String -> Decoder RelatedTo
relatedToConverter typeString =
    case typeString of
        "rism:Institution" ->
            Decode.succeed InstitutionRelationship

        "rism:Person" ->
            Decode.succeed PersonRelationship

        "rism:Place" ->
            Decode.succeed PlaceRelationship

        "rism:Source" ->
            Decode.succeed SourceRelationship

        _ ->
            Decode.succeed UnknownRelationship


relatedToTypeDecoder : Decoder RelatedTo
relatedToTypeDecoder =
    string
        |> andThen relatedToConverter


relationshipBodyDecoder : Decoder RelationshipBody
relationshipBodyDecoder =
    Decode.succeed RelationshipBody
        |> optional "role" (Decode.maybe roleBodyDecoder) Nothing
        |> optional "qualifier" (Decode.maybe qualifierBodyDecoder) Nothing
        |> optional "relatedTo" (Decode.maybe relatedToBodyDecoder) Nothing
        |> optional "name" (Decode.maybe languageMapLabelDecoder) Nothing
        |> optional "note" (Decode.maybe languageMapLabelDecoder) Nothing


relationshipsSectionBodyDecoder : Decoder RelationshipsSectionBody
relationshipsSectionBodyDecoder =
    Decode.succeed RelationshipsSectionBody
        |> hardcoded "record-relationships-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list relationshipBodyDecoder)


roleBodyDecoder : Decoder RoleBody
roleBodyDecoder =
    Decode.succeed RoleBody
        |> required "label" languageMapLabelDecoder
        |> required "value" string
        |> optional "id" roleDecoder UnknownRole


roleConverter : String -> Decoder RelationshipRole
roleConverter roleString =
    Dict.fromList roleMap
        |> Dict.get roleString
        |> Maybe.withDefault UnknownRole
        |> Decode.succeed


roleDecoder : Decoder RelationshipRole
roleDecoder =
    string
        |> andThen roleConverter


{-|

    Maps the expected values of the 'role' in the JSON response to
    a type-defined value.

-}
roleMap : List ( String, RelationshipRole )
roleMap =
    [ ( "relators:arr", ArrangerRole )
    , ( "relators:asg", AssigneeRole )
    , ( "relators:asn", AssociatedNameRole )
    , ( "relators:aut", AuthorRole )
    , ( "relators:bsl", BooksellerRole )
    , ( "relators:ccp", ConceptorRole )
    , ( "relators:cmp", ComposerRole )
    , ( "relators:cns", CensorRole )
    , ( "relators:cph", CopyrightHolderRole )
    , ( "relators:cre", ComposerAuthorRole )
    , ( "relators:ctb", ContributorRole )
    , ( "relators:dpt", DepositorRole )
    , ( "relators:dst", DistributorRole )
    , ( "relators:dte", DedicateeRole )
    , ( "relators:edt", EditorRole )
    , ( "relators:egr", EngraverRole )
    , ( "relators:evp", EventPlaceRole )
    , ( "relators:fmo", FormerOwnerRole )
    , ( "relators:ill", IllustratorRole )
    , ( "relators:lbt", LibrettistRole )
    , ( "relators:lse", LicenseeRole )
    , ( "relators:ltg", LithographerRole )
    , ( "relators:lyr", LyricistRole )
    , ( "relators:oth", OtherRole )
    , ( "relators:pbl", PublisherRole )
    , ( "relators:ppm", PapermakerRole )
    , ( "relators:prf", PerformerRole )
    , ( "relators:prt", PrinterRole )
    , ( "relators:scr", CopyistRole )
    , ( "relators:trl", TranslatorRole )
    , ( "relators:tyd", TypeDesignerRole )
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
