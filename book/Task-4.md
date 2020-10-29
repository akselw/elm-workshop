# Other tasks

## Task 4.1: Create a view element for `input`

Create view element for `input`, which is a single line text input,
in contrast with a `textarea`, which is a text box.

Use a similar API for the `Input` module as is used in `Textarea`.

The HTML can look like this:

```elm
    div [ class "form-element" ]
        [ label [ class "label" ]
            [ span [ class "label-text" ] [ text "Label" ]
            , Html.input
                [ class "input"
                , classList [ ( "error", True ) ]
                , value "Some text"
                , onInput msg
                ]
                []
            ,
            div [ role "alert", ariaLive "assertive" ]
                [ p [ class "error-message" ] [ text "Error message" ] ]
            ]
        ]
```

## Task 4.2 Add a username to a comment (using Input)

The endpoint for POST-ing a comment also supports a `"username"` field,
which is a string.

## Task 4.3

Make the username, and the comment text, a form,
using the way to make forms from [this repo](https://github.com/akselw/elm-skjema-demo/tags).
You can check out the tags in that repo to see a progression of how the form is built.
