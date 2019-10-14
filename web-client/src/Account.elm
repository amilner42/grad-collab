module Account exposing (AccountData, blankFields, decoder, emptyData, encode)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import ListUtil


type alias AccountData =
    { name : String
    , field : String
    , specialization : String
    , currentAvailability : String
    , supervisorEmail : String
    , researchExperience : String
    , university : String
    , degreesHeld : String
    , shortBio : String
    , linkedInUrl : String
    , researchPapers : String
    }


emptyData : AccountData
emptyData =
    { name = ""
    , field = ""
    , specialization = ""
    , currentAvailability = ""
    , supervisorEmail = ""
    , researchExperience = ""
    , university = ""
    , degreesHeld = ""
    , shortBio = ""
    , linkedInUrl = ""
    , researchPapers = ""
    }


blankFields : AccountData -> List String
blankFields accountData =
    ListUtil.filterByBool
        [ ( String.isEmpty accountData.name, "name" )
        , ( String.isEmpty accountData.field, "field" )
        , ( String.isEmpty accountData.specialization, "specialization" )
        , ( String.isEmpty accountData.currentAvailability, "currentAvailability" )
        , ( String.isEmpty accountData.supervisorEmail, "supervisorEmail" )
        , ( String.isEmpty accountData.researchExperience, "researchExperience" )
        , ( String.isEmpty accountData.university, "university" )
        , ( String.isEmpty accountData.degreesHeld, "degreesHeld" )
        , ( String.isEmpty accountData.shortBio, "shortBio" )
        , ( String.isEmpty accountData.linkedInUrl, "linkedInUrl" )
        , ( String.isEmpty accountData.researchPapers, "researchPapers" )
        ]


encode : AccountData -> Encode.Value
encode accountData =
    Encode.object
        [ ( "name", Encode.string accountData.name )
        , ( "field", Encode.string accountData.field )
        , ( "specialization", Encode.string accountData.specialization )
        , ( "currentAvailability", Encode.string accountData.currentAvailability )
        , ( "supervisorEmail", Encode.string accountData.supervisorEmail )
        , ( "researchExperience", Encode.string accountData.researchExperience )
        , ( "university", Encode.string accountData.university )
        , ( "degreesHeld", Encode.string accountData.degreesHeld )
        , ( "shortBio", Encode.string accountData.shortBio )
        , ( "linkedInUrl", Encode.string accountData.linkedInUrl )
        , ( "researchPapers", Encode.string accountData.researchPapers )
        ]


decoder : Decode.Decoder AccountData
decoder =
    Decode.succeed AccountData
        |> required "name" Decode.string
        |> required "field" Decode.string
        |> required "specialization" Decode.string
        |> required "currentAvailability" Decode.string
        |> required "supervisorEmail" Decode.string
        |> required "researchExperience" Decode.string
        |> required "university" Decode.string
        |> required "degreesHeld" Decode.string
        |> required "shortBio" Decode.string
        |> required "linkedInUrl" Decode.string
        |> required "researchPapers" Decode.string
