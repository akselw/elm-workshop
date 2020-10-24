# Task 2 - Sending the comment to the server

We are now able to view and update a string,
containing the text that a user wants to comment on the article.
But commenters also want _other people_ to view their comments,
so we therefore have to send the comments in the model to the server,
so it can be stored there, and served to other users.

Before we start with sending the comment to the server,
we will change how we represent our comment in the model,
so that we allow for all the states we plan to implement.

## Task 2.1: A custom type for new comments

It is often useful to create custom types to represent a part of the app state,
for instance when fetching or sending data to and from the server is involved.
When making such a custom type, it is useful to take a couple of minutes to consider
what states we want to enable in our app, and how best to represent those states.

On this page we have a text area for commenting that we always want to be visible.
When the user wants to post their comment, they will click a button to send their comment to the server.
There will then be some delay while the request is processed by the server,
this might take a couple of milliseconds or multiple seconds,
depending on a lot of factors (the users Internet speed, the speed of the server etc.),
so we should account for this state, even though it will be very quickly while developing.
After some time the server will respond to our request, with either a response or an error.
We therefore need a state for the error case,
but we actually won't need a state for the success case:
in that case we can just go back to the initial state.

Given the reasoning above, we could make a custom type like this to represent our comment state:

```elm
type NewCommentState
    = WritingComment
    | SavingComment
    | ErrorSavingComment
```

This is a good starting point, but we want to add some additional stuff to our type.
We might, for instance, want to give the user some feedback about _what_ went wrong
in the case of an error
(did the user lose their internet connection? Or maybe we just couldn't parse the response).
We will also add the comment text string to our comment state.
We will start by adding a `String` to each of the possible states,
but we will change this string to something else later.

1. Paste in the following custom type in `src/Page/Article.elm`:
    ```elm
    type NewCommentState
        = WritingComment String
        | SavingComment String
        | ErrorSavingComment String Http.Error
    ```
    If you get a compilation error, you might want to add the following line to toward the top of the file:
    ```elm
    import Http
    ```

2. Add a field `newCommentState: NewCommentState` to `SuccessModel`,
and follow the compilation errors until your code compiles.
(Don't delete the `commentText` field quite yet!
It is easier to do this change in multiple steps)

3. Add a case statement to the `viewWriteComment` function, like the following code,
where you replace `...` with the previous body of the `viewWriteComment` function.
    ```elm
    viewWriteComment : SuccessModel -> Html Msg
    viewWriteComment successModel =
        case successModel.newCommentState of
            WritingComment commentText ->
               ...

            _ ->
                text ""
    ```
    (`text ""` returns HTML without any content,
    and is useful when you don't want your view function to display anything)

4. Change from using the `commentText` field in `successModel`
to using `commentText` from the comment state.
(You should change the line above `|> Textarea.textarea { ... }`)

    When using your app now, typing in the comment field won't result in visible changes.
    To make that work again, we have to change the `update` function.

5. Add a new case statement in the success case for `CommentUpdated` in the update function,
that checks that the comment state is `WritingComment`.
    ```elm
    CommentUpdated string ->
        case model of
            Success successModel ->
                --- Add case statement here
    ```

6. If you didn't do it in the previous step:
change from updating the `commentText` field to updating `newCommentState` with the string from the message.

    Your app should now work exactly like it did before we introduced `newCommentState`,
    and the `commentText` field should only be initialized in `init`, but never read or changed.
    It's therefore now safe and easy to delete the field!

7. Delete the `commentText` field from the `SuccessModel` type alias,
and follow the compilation errors until your code compiles again.

By making small changes, we have refactored a part of our code
in a way that enable us to add some functionality in the tasks to come.
This is a useful technique in Elm, because even though the compiler has our back,
small changes make it easier to make big changes.

## Task 2.2: Adding a Post button

Next, we will add a button that the user can click to post their comment.

1. Add a new message `PostCommentButtonClicked` to the `Msg` type
(the message shouldn't have any arguments),
and add a case for the new message in the `update` function.
You can just return `( model, Cmd.none )` from `update` in that case.

2. Add the following code to `viewWriteComment`, after the `TextArea`:
    ```elm
    Container.buttonRow
        [ Button.button PostCommentButtonClicked "Post"
            |> Button.toHtml
        ]
    ```

   The `Container.buttonRow` is just to make the layout right.

That's it for adding the button. Next, we will actually make the request to the server!

By the way, we won't come back to the view for the `SavingComment` and `ErrorSavingComment` states,
so if you want, you can try to implement those on your own.
The `Button` module has a function for adding a spinner, which you could use in the loading state.
And to test the views for the different states, you could change the state in `init`,
since we haven't implemented that yet.

## Task 2.3: Making a request to the server

