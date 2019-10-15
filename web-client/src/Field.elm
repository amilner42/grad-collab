module Field exposing (Field(..), decoder, encoder, fromString, toString)

import Json.Decode as Decode
import Json.Encode as Encode


type Field
    = Math
    | Stats
    | ComputerScience
    | Biology
    | Physics
    | Chemistry


fromString : String -> Maybe Field
fromString str =
    case str of
        "Math" ->
            Just Math

        "Stats" ->
            Just Stats

        "Computer Science" ->
            Just ComputerScience

        "Biology" ->
            Just Biology

        "Physics" ->
            Just Physics

        "Chemistry" ->
            Just Chemistry

        _ ->
            Nothing


toString : Field -> String
toString field =
    case field of
        Math ->
            "Math"

        Stats ->
            "Stats"

        ComputerScience ->
            "Computer Science"

        Biology ->
            "Biology"

        Physics ->
            "Physics"

        Chemistry ->
            "Chemistry"


encoder : Field -> Encode.Value
encoder =
    toString >> Encode.string


decoder : Decode.Decoder Field
decoder =
    Decode.string
        |> Decode.andThen
            (\asStr ->
                let
                    asField =
                        fromString asStr
                in
                case asField of
                    Nothing ->
                        Decode.fail <| "Invalid field type: " ++ asStr

                    Just field ->
                        Decode.succeed field
            )
