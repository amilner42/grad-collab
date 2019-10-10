module CollabRequest exposing (CollabRequestData, empty, encode)

import Api.Errors.Form as FormError
import Json.Encode as Encode


type alias CollabRequestData =
    { field : String
    , subject : String
    , projectImpactSummary : String
    , expectedTasks : String
    , expectedSkills : String
    , expectedTime : String
    , offer : String
    , additionalInfo : String
    }


empty : CollabRequestData
empty =
    { field = ""
    , subject = ""
    , projectImpactSummary = ""
    , expectedTasks = ""
    , expectedSkills = ""
    , expectedTime = ""
    , offer = ""
    , additionalInfo = ""
    }


dataGoodForSubmission : CollabRequestData -> FormError.Error
dataGoodForSubmission collabRequest =
    FormError.fromFieldErrors <|
        FormError.fieldErrorsFromList
            [ ( "field", Nothing )
            , ( "subject", Nothing )
            ]


encode : CollabRequestData -> Encode.Value
encode collabRequest =
    Encode.object
        [ ( "field", Encode.string collabRequest.field )
        , ( "subject", Encode.string collabRequest.subject )
        , ( "projectImpactSummary", Encode.string collabRequest.projectImpactSummary )
        , ( "expectedTasks", Encode.string collabRequest.expectedTasks )
        , ( "expectedSkills", Encode.string collabRequest.expectedSkills )
        , ( "expectedTime", Encode.string collabRequest.expectedTime )
        , ( "offer", Encode.string collabRequest.offer )
        , ( "additionalInfo", Encode.string collabRequest.additionalInfo )
        ]
