module Comment exposing (Comment, text, username)

import CommentId exposing (CommentId)


type Comment
    = Comment CommentInfo


type alias CommentInfo =
    { text : String
    , id : CommentId
    , username : String
    }



--- CONTENTS ---


text : Comment -> String
text (Comment info) =
    info.text


username : Comment -> String
username (Comment info) =
    info.username



--- DECODING ---
