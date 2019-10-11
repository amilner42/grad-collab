module CollabRequest exposing (CollabRequest, CollabRequestData, decoder, empty, encode)

import Api.Errors.Form as FormError
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode


type alias CollabRequest =
    { id : String
    , field : String
    , subject : String
    , projectImpactSummary : String
    , expectedTasks : String
    , expectedSkills : String
    , expectedTime : String
    , offer : String
    , additionalInfo : String
    , userId : String
    , invitedCollabs : List String
    }


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


decoder : Decode.Decoder CollabRequest
decoder =
    Decode.succeed CollabRequest
        |> required "_id" Decode.string
        |> required "field" Decode.string
        |> required "subject" Decode.string
        |> required "projectImpactSummary" Decode.string
        |> required "expectedTasks" Decode.string
        |> required "expectedSkills" Decode.string
        |> required "expectedTime" Decode.string
        |> required "offer" Decode.string
        |> required "additionalInfo" Decode.string
        |> required "userId" Decode.string
        |> required "invitedCollabs" (Decode.list Decode.string)
