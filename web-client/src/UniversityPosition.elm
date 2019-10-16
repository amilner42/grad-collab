module UniversityPosition exposing (UniversityPosition(..), decoder, encode, fromString, hasSupervisor, toString)

import Json.Decode as Decode
import Json.Encode as Encode


type UniversityPosition
    = Undergrad
    | Masters
    | PHD
    | PostDoc
    | Instructor
    | AssistantProfessor
    | Professor


toString : UniversityPosition -> String
toString universityPosition =
    case universityPosition of
        Undergrad ->
            "Undergrad"

        Masters ->
            "Masters"

        PHD ->
            "PHD"

        PostDoc ->
            "Post Doc"

        Instructor ->
            "Instructor"

        AssistantProfessor ->
            "Assistant Professor"

        Professor ->
            "Professor"


fromString : String -> Maybe UniversityPosition
fromString asStr =
    case asStr of
        "Undergrad" ->
            Just Undergrad

        "Masters" ->
            Just Masters

        "PHD" ->
            Just PHD

        "Post Doc" ->
            Just PostDoc

        "Instructor" ->
            Just Instructor

        "Assistant Professor" ->
            Just AssistantProfessor

        "Professor" ->
            Just Professor

        _ ->
            Nothing


hasSupervisor : UniversityPosition -> Bool
hasSupervisor universityPosition =
    case universityPosition of
        Undergrad ->
            True

        Masters ->
            True

        PHD ->
            True

        PostDoc ->
            True

        Instructor ->
            False

        AssistantProfessor ->
            False

        Professor ->
            False


encode : UniversityPosition -> Encode.Value
encode =
    toString >> Encode.string


decoder : Decode.Decoder UniversityPosition
decoder =
    Decode.string
        |> Decode.andThen
            (\asStr ->
                let
                    asUniversityPosition =
                        fromString asStr
                in
                case asUniversityPosition of
                    Nothing ->
                        Decode.fail <| "Invalid university position type: " ++ asStr

                    Just universityPosition ->
                        Decode.succeed universityPosition
            )
