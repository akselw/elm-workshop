module CommentForm exposing
    ( CommentForm
    , ValidatedCommentForm
    , encode
    , init
    , showAllErrors
    , showTextErrorMessage
    , showUsernameErrorMessage
    , text
    , textError
    , updateText
    , updateUsername
    , username
    , usernameError
    , validate
    )

import Json.Encode


type CommentForm
    = CommentForm CommentFormInfo


type alias CommentFormInfo =
    { text : String
    , username : String
    , showTextErrorMessage : Bool
    , showUsernameErrorMessage : Bool
    }


init : CommentForm
init =
    CommentForm
        { text = ""
        , username = ""
        , showTextErrorMessage = False
        , showUsernameErrorMessage = False
        }



--- CONTENTS ---


text : CommentForm -> String
text (CommentForm form) =
    form.text


username : CommentForm -> String
username (CommentForm form) =
    form.username



--- UPDATING ---


updateText : CommentForm -> String -> CommentForm
updateText (CommentForm form) string =
    CommentForm { form | text = string }


updateUsername : CommentForm -> String -> CommentForm
updateUsername (CommentForm form) string =
    CommentForm { form | username = string }



--- ERRORS ---


textError : CommentForm -> Maybe String
textError (CommentForm form) =
    if form.showTextErrorMessage then
        textErrorMessage form

    else
        Nothing


textErrorMessage : CommentFormInfo -> Maybe String
textErrorMessage form =
    if (String.toLower >> String.contains "typeclass") form.text then
        Just "Do not mention typeclasses"

    else if (String.trim >> String.isEmpty) form.text then
        Just "This field is required"

    else
        Nothing


usernameError : CommentForm -> Maybe String
usernameError (CommentForm form) =
    if form.showUsernameErrorMessage then
        usernameErrorMessage form

    else
        Nothing


usernameErrorMessage : CommentFormInfo -> Maybe String
usernameErrorMessage form =
    if (String.trim >> String.isEmpty) form.username then
        Just "This field is required"

    else
        Nothing


showTextErrorMessage : CommentForm -> CommentForm
showTextErrorMessage (CommentForm form) =
    CommentForm { form | showTextErrorMessage = True }


showUsernameErrorMessage : CommentForm -> CommentForm
showUsernameErrorMessage (CommentForm form) =
    CommentForm { form | showUsernameErrorMessage = True }


showAllErrors : CommentForm -> CommentForm
showAllErrors form =
    form
        |> showTextErrorMessage
        |> showUsernameErrorMessage



--- VALIDATION ---


type ValidatedCommentForm
    = ValidatedCommentForm
        { text : String
        , username : String
        }


validate : CommentForm -> Maybe ValidatedCommentForm
validate (CommentForm form) =
    case ( textErrorMessage form, usernameErrorMessage form ) of
        ( Nothing, Nothing ) ->
            Just
                (ValidatedCommentForm
                    { text = form.text
                    , username = form.username
                    }
                )

        _ ->
            Nothing



--- ENCODE ---


encode : ValidatedCommentForm -> Json.Encode.Value
encode (ValidatedCommentForm form) =
    Json.Encode.object
        [ ( "text", Json.Encode.string form.text )
        , ( "username", Json.Encode.string form.username )
        ]
