module Account exposing (AccountData, emptyData)


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
