module Comment exposing (Comment, decoder, subcomments, text, username)

import CommentId exposing (CommentId)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


type Comment
    = Comment CommentInfo


type alias CommentInfo =
    { text : String
    , id : CommentId
    , username : String
    , subcomments : List Comment
    }



--- CONTENTS ---


text : Comment -> String
text (Comment info) =
    info.text


username : Comment -> String
username (Comment info) =
    info.username


subcomments : Comment -> List Comment
subcomments (Comment info) =
    info.subcomments



--- DECODING ---


decoder : Decoder Comment
decoder =
    commentInfoDecoder
        |> Json.Decode.map Comment


commentInfoDecoder : Decoder CommentInfo
commentInfoDecoder =
    Json.Decode.succeed CommentInfo
        |> required "text" Json.Decode.string
        |> required "id" CommentId.decode
        |> required "username" Json.Decode.string
        |> optional "comments" (Json.Decode.list (Json.Decode.lazy (\_ -> decoder))) []
