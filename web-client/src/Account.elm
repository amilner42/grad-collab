module Account exposing (AccountData, emptyData, encode)

import Json.Encode as Encode


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
