module Records.DataTypes exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Device)
import Http
import Shared.DataTypes exposing (LabelValue, RecordType)
import Shared.Language exposing (Language, LanguageMap)
import Url exposing (Url)


type Msg
    = ReceivedRecordResponse (Result Http.Error RecordResponse)
    | UrlRequest UrlRequest
    | UrlChanged Url
    | OnWindowResize Device
    | LanguageSelectChanged String
    | NoOp


type alias Model =
    { key : Nav.Key
    , url : Url
    , response : ApiResponse
    , errorMessage : String
    , language : Language
    , viewingDevice : Device
    }


type Route
    = SourceRoute Int
    | PersonRoute Int
    | InstitutionRoute Int
    | PlaceRoute Int
    | NotFound


type ApiResponse
    = Loading
    | Response RecordResponse
    | ApiError


type IncipitFormat
    = RenderedSVG
    | RenderedMIDI
    | UnknownFormat


type alias Relations =
    { label : LanguageMap
    , items : List RelationshipList
    , type_ : String
    }


type alias RelationshipList =
    { label : LanguageMap
    , items : List Relationship
    , type_ : String
    }


type alias Relationship =
    { id : Maybe String
    , type_ : String
    , role : Maybe LanguageMap
    , qualifier : Maybe LanguageMap
    , relatedTo : Maybe RelatedEntity
    , value : Maybe LanguageMap
    }


{-| -}
type alias RelatedEntity =
    { type_ : RecordType
    , label : LanguageMap
    , id : String
    }


type alias ExternalResource =
    { url : String
    , label : LanguageMap
    }


type alias ExternalResourceList =
    { label : LanguageMap
    , items : List ExternalResource
    }


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , sourceType : LanguageMap
    }


type alias Subject =
    { id : String
    , term : LanguageMap
    }


type alias NoteList =
    { label : LanguageMap
    , notes : List LabelValue
    }


type RenderedIncipit
    = RenderedIncipit IncipitFormat String


type alias Incipit =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , rendered : Maybe (List RenderedIncipit)
    }


type alias IncipitList =
    { label : LanguageMap
    , incipits : List Incipit
    }


type alias MaterialGroupList =
    { label : LanguageMap
    , items : List MaterialGroup
    }


type alias MaterialGroup =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , related : Maybe Relations
    }


type alias ExemplarList =
    { id : String
    , label : LanguageMap
    , items : List Exemplar
    }


type alias Exemplar =
    { id : String
    , summary : List LabelValue
    , heldBy : InstitutionBody
    }


type alias SourceBody =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , sourceType : LanguageMap
    , partOf : Maybe (List BasicSourceBody)
    , creator : Maybe Relationship
    , related : Maybe Relations
    , subjects : Maybe (List Subject)
    , notes : Maybe NoteList
    , incipits : Maybe IncipitList
    , materialgroups : Maybe MaterialGroupList
    , exemplars : Maybe ExemplarList
    }


type alias PersonBody =
    { id : String
    , label : LanguageMap
    , sources : Maybe PersonSources
    , summary : List LabelValue
    , seeAlso : Maybe (List SeeAlso)
    , nameVariants : Maybe PersonNameVariantList
    , related : Maybe RelatedList
    , notes : Maybe NoteList
    , externalResources : Maybe ExternalResourceList
    }


type alias PersonSources =
    { id : String
    , totalItems : Int
    }


type alias Relationships =
    { label : LanguageMap
    , items : List Relationship
    }


type alias RelatedList =
    { label : LanguageMap
    , items : List Relationships
    }


type alias PersonNameVariantList =
    { label : LanguageMap
    , items : List LabelValue
    }


type alias SeeAlso =
    { url : String
    , label : LanguageMap
    }


type alias InstitutionBody =
    { id : String
    , label : LanguageMap
    , summary : List LabelValue
    , related : Maybe RelatedList
    }


type alias PlaceBody =
    { id : String
    , label : LanguageMap
    }


type RecordResponse
    = SourceResponse SourceBody
    | PersonResponse PersonBody
    | InstitutionResponse InstitutionBody
    | PlaceResponse PlaceBody
