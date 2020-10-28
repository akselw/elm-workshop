# Task 1 - Writing comments

We will work in the page that displays a single article.
Navigate to the app at [localhost:8080](http://localhost:8080),
and choose the article at the top called "Modelling in Elm".
The code for the article pages is located in `src/Page/Article` (not `Articles`).
You don't have to understand everything in the page,
we will go through the most important pieces.

In this task, we will add the ability to write a comment on an article.
We will store the text of the comment in the model,
and display the text written thus far in the view.

We will start with the simplest approach possible: a simple `String` in the model.
In subsequent tasks, we will change this,
to allow for a more correct representation of our app state.

The model is currently a custom type representing the various states of fetching
an article that the app can be in on this page:

```elm
type Model
    = Loading
    | Failure Http.Error
    | Success SuccessModel
```

And `SuccessModel` is the part of the model containing the parts of the app state
that are relevant after the fetching of the article is complete.
Currently it only contains a single field, for the article that has been fetched:

```elm
type alias SuccessModel =
    { article : Article
    }
```

## Task 1.1: Add comment text to model

1. Add a field `commentText` of type `String` to `SuccessModel`
2. Fix the compiler errors until your app compiles again.

You should see your empty `commentText` field in the Elm debugger in the browser.

## Task 1.2: Add a text area to the view

Next, we want to display what is in the model in the view.
Currently there is a function called `viewSuccess`, which looks like this:

```elm
viewSuccess : SuccessModel -> List (Html Msg)
viewSuccess successModel =
    [ viewArticle successModel.article
    ]
```

1. Paste in the following function, for displaying a text area:
    ```elm
    viewWriteComment : SuccessModel -> Html Msg
    viewWriteComment successModel =
        div [ class "write-new-comment" ]
            [ "Example text"
                |> Textarea.textarea { label = "Add comment", onInput = CommentUpdated }
                |> Textarea.toHtml
            ]
    ```
2. Call the function `viewWriteComment` from `viewSuccess`
by adding it as the second element in the list, after the call to `viewArticle`.
You should now see a text area below the article in the browser.

3. Notice that the text area in the browser contains the text "Example text".
Change `viewWriteComment` to use the text in `SuccessModel`.
You can change the text in `init` to make sure the view is rendering what is in the model.

## Task 1.3: Update the model when the user types

You may have noticed that the text in the text area never changes:
it always just displays whatever is in the model.
While we want the view to display whatever is in the model,
we also want the model to change whenever a user types something.
We do this in the `update` function.

The `update` function has the following case for the message `CommentUpdated`:

```elm
CommentUpdated string ->
    ( model, Cmd.none )
```

1. Change this to check with a `case`-expression whether the model is
currently in the `Success` state, so that `SuccessModel` is available.
You can still return `( model, Cmd.none )` in both the cases, for now.

2. Update the model in the `Success` case,
so that the string sent with the message is stored in the `commentText` field.

The comment text area should now update when you type!

Next, we will start to prepare for sending the new comment to the server.

