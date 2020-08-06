module CommentForm exposing
    ( CommentForm
    , ValidatedCommentForm
    , encode
    , init
    , showAllErrors
    , showTextErrorMessage
    , text
    , textError
    , updateText
    , validate
    )

import Json.Encode


type CommentForm
    = CommentForm { text : String, showTextErrorMessage : Bool }


init : CommentForm
init =
    CommentForm
        { text = ""
        , showTextErrorMessage = False
        }


text : CommentForm -> String
text (CommentForm form) =
    form.text


updateText : CommentForm -> String -> CommentForm
updateText (CommentForm form) string =
    CommentForm { form | text = string }



--- ERRORS ---


textError : CommentForm -> Maybe String
textError (CommentForm form) =
    if form.showTextErrorMessage then
        textErrorMessage form.text

    else
        Nothing


textErrorMessage : String -> Maybe String
textErrorMessage string =
    if (String.toLower >> String.contains "typeclass") string then
        Just "Do not mention typeclasses"

    else
        Nothing


showTextErrorMessage : CommentForm -> CommentForm
showTextErrorMessage (CommentForm form) =
    CommentForm { form | showTextErrorMessage = True }


showAllErrors : CommentForm -> CommentForm
showAllErrors form =
    form
        |> showTextErrorMessage



--- VALIDATION ---


type ValidatedCommentForm
    = ValidatedCommentForm { text : String }


validate : CommentForm -> Maybe ValidatedCommentForm
validate (CommentForm form) =
    case textErrorMessage form.text of
        Just _ ->
            Nothing

        Nothing ->
            Just (ValidatedCommentForm { text = form.text })



--- ENCODE ---


encode : ValidatedCommentForm -> Json.Encode.Value
encode (ValidatedCommentForm form) =
    Json.Encode.object [ ( "text", Json.Encode.string form.text ) ]
