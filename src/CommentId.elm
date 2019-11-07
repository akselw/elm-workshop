module CommentId exposing (CommentId, decode)

import Json.Decode exposing (Decoder)


type CommentId
    = CommentId String



--- DECODING ---


decode : Decoder CommentId
decode =
    Json.Decode.string
        |> Json.Decode.map CommentId
