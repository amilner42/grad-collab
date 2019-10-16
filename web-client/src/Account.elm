module Account exposing (AccountData, blankFields, decoder, emptyData, encode)

import EncodeUtil
import Field exposing (Field)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import ListUtil
import UniversityPosition exposing (UniversityPosition)


type alias AccountData =
    { name : String
    , universityPosition : Maybe UniversityPosition
    , field : Maybe Field
    , specialization : String
    , currentAvailability : String
    , supervisorEmail : String
    , researchExperienceAndPapers : String
    , university : String
    , degreesHeld : String
    , shortBio : String
    , linkedInUrl : String
    }


emptyData : AccountData
emptyData =
    { name = ""
    , universityPosition = Nothing
    , field = Nothing
    , specialization = ""
    , currentAvailability = ""
    , supervisorEmail = ""
    , researchExperienceAndPapers = ""
    , university = ""
    , degreesHeld = ""
    , shortBio = ""
    , linkedInUrl = ""
    }


blankFields : AccountData -> List String
blankFields accountData =
    ListUtil.filterByBool
        [ ( String.isEmpty accountData.name, "name" )
        , ( accountData.universityPosition == Nothing, "universityPosition" )
        , ( accountData.field == Nothing, "field" )
        , ( String.isEmpty accountData.specialization, "specialization" )
        , ( String.isEmpty accountData.currentAvailability, "currentAvailability" )
        , ( String.isEmpty accountData.supervisorEmail, "supervisorEmail" )
        , ( String.isEmpty accountData.researchExperienceAndPapers, "researchExperienceAndPapers" )
        , ( String.isEmpty accountData.university, "university" )
        , ( String.isEmpty accountData.degreesHeld, "degreesHeld" )
        , ( String.isEmpty accountData.shortBio, "shortBio" )
        , ( String.isEmpty accountData.linkedInUrl, "linkedInUrl" )
        ]


encode : AccountData -> Encode.Value
encode accountData =
    Encode.object
        [ ( "name", Encode.string accountData.name )
        , ( "universityPosition", EncodeUtil.nullable UniversityPosition.encode accountData.universityPosition )
        , ( "field", EncodeUtil.nullable Field.encoder accountData.field )
        , ( "specialization", Encode.string accountData.specialization )
        , ( "currentAvailability", Encode.string accountData.currentAvailability )
        , ( "supervisorEmail", Encode.string accountData.supervisorEmail )
        , ( "researchExperienceAndPapers", Encode.string accountData.researchExperienceAndPapers )
        , ( "university", Encode.string accountData.university )
        , ( "degreesHeld", Encode.string accountData.degreesHeld )
        , ( "shortBio", Encode.string accountData.shortBio )
        , ( "linkedInUrl", Encode.string accountData.linkedInUrl )
        ]


decoder : Decode.Decoder AccountData
decoder =
    Decode.succeed AccountData
        |> required "name" Decode.string
        |> required "universityPosition" (Decode.nullable UniversityPosition.decoder)
        |> required "field" (Decode.nullable Field.decoder)
        |> required "specialization" Decode.string
        |> required "currentAvailability" Decode.string
        |> required "supervisorEmail" Decode.string
        |> required "researchExperienceAndPapers" Decode.string
        |> required "university" Decode.string
        |> required "degreesHeld" Decode.string
        |> required "shortBio" Decode.string
        |> required "linkedInUrl" Decode.string
