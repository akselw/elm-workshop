module CommentId exposing (CommentId, decode, toString)

import Json.Decode exposing (Decoder)


type CommentId
    = CommentId String


toString : CommentId -> String
toString (CommentId id) =
    id



--- DECODING ---


decode : Decoder CommentId
decode =
    Json.Decode.string
        |> Json.Decode.map CommentId
