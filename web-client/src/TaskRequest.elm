module TaskRequest exposing (TaskRequest, TaskRequestData, TaskRequestWithOwner, decoder, empty, encode, taskRequestWithOwnerDecoder)

import Api.Errors.Form as FormError
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import User exposing (User)


type alias TaskRequest =
    { id : String
    , field : String
    , subject : String
    , projectImpactSummary : String
    , expectedTasksAndSkills : String
    , reward : String
    , additionalInfo : String
    , userId : String
    }


type alias TaskRequestData =
    { field : String
    , subject : String
    , projectImpactSummary : String
    , expectedTasksAndSkills : String
    , reward : String
    , additionalInfo : String
    }


type alias TaskRequestWithOwner =
    { owner : User
    , taskRequest : TaskRequest
    }


empty : TaskRequestData
empty =
    { field = ""
    , subject = ""
    , projectImpactSummary = ""
    , expectedTasksAndSkills = ""
    , reward = ""
    , additionalInfo = ""
    }


dataGoodForSubmission : TaskRequestData -> FormError.Error
dataGoodForSubmission taskRequest =
    FormError.fromFieldErrors <|
        FormError.fieldErrorsFromList
            [ ( "field", Nothing )
            , ( "subject", Nothing )
            ]


encode : TaskRequestData -> Encode.Value
encode taskRequest =
    Encode.object
        [ ( "field", Encode.string taskRequest.field )
        , ( "subject", Encode.string taskRequest.subject )
        , ( "projectImpactSummary", Encode.string taskRequest.projectImpactSummary )
        , ( "expectedTasksAndSkills", Encode.string taskRequest.expectedTasksAndSkills )
        , ( "reward", Encode.string taskRequest.reward )
        , ( "additionalInfo", Encode.string taskRequest.additionalInfo )
        ]


decoder : Decode.Decoder TaskRequest
decoder =
    Decode.succeed TaskRequest
        |> required "_id" Decode.string
        |> required "field" Decode.string
        |> required "subject" Decode.string
        |> required "projectImpactSummary" Decode.string
        |> required "expectedTasksAndSkills" Decode.string
        |> required "reward" Decode.string
        |> required "additionalInfo" Decode.string
        |> required "userId" Decode.string


taskRequestWithOwnerDecoder : Decode.Decoder TaskRequestWithOwner
taskRequestWithOwnerDecoder =
    Decode.succeed TaskRequestWithOwner
        |> required "user" User.decoder
        |> required "taskRequest" decoder
