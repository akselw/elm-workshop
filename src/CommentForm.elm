module CommentForm exposing
    ( CommentForm
    , ValidatedCommentForm
    , init
    , text
    , updateText
    , validate
    )


type CommentForm
    = CommentForm { text : String }


init : CommentForm
init =
    CommentForm { text = "" }


text : CommentForm -> String
text (CommentForm form) =
    form.text


updateText : CommentForm -> String -> CommentForm
updateText (CommentForm form) string =
    CommentForm { form | text = string }



--- VALIDATION ---


type ValidatedCommentForm
    = ValidatedCommentForm { text : String }


validate : CommentForm -> Maybe ValidatedCommentForm
validate (CommentForm form) =
    Just (ValidatedCommentForm { text = form.text })
