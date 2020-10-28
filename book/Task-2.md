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

That's it for adding the button.
You can check that the right message is sent in the Elm debugger in the browser.
Next, we will actually make the request to the server!

By the way, we won't come back to the view for the `SavingComment` and `ErrorSavingComment` states,
so if you want, you can try to implement those on your own.
The `Button` module has a function for adding a spinner, which you could use in the loading state.
To test the views for the different states, you could change the state in `init`,
since we haven't implemented that yet.

## Task 2.3: Making a request to the server

To post a comment to the server, we are going to be making an HTTP request.
The server expects a `POST` request to the URL `/api/article/{articleId}/comments`
where `{articleId}` is the ID of the article the user is commenting on.
The server expects the request to have a body that looks like this:

```json
{
  "text": "The text of the comment."
}
```

We will go through how to construct this request piece by piece.

The Http-package in Elm has a function for creating a POST request with the following type signature:

```elm
post : { url : String , body : Body , expect : Expect msg } -> Cmd msg
```

The `post` function takes one argument, which is a record with three fields:
`url`, `body`, and `expect`.
The `url` field is just a `String`, which is pretty straight foreward.
The `body` field is a `Body`, which the `Http` module has functions for creating.
And the `expect` field is of type `Expect msg`, which is a type in the `Http` module
describing what we expect the server to return as a response to our request.
The function returns a `Cmd msg`.

Since calling the `post` function will give us `Cmd msg`,
we can use that `Cmd` as the second part of the tuple we return from `update`,
where we have just return `Cmd.none` until now.

To make the most minimal `POST` request we can (that doesn't actually do what we want yet),
we can use the following code:

```elm
Http.post
    { url = "/api/article/" ++ "dummy_id" ++ "/comments"
    , body = Http.emptyBody
    , expect = Http.expectWhatever SavingCommentFinished
    }
```

 This will create a `POST` request to `"/api/article/dummy_id/comments"`, with an empty body,
 and it won't care about what the server returns.
 The argument to `Http.expectWhatever` is a message that we haven't created yet.
 The message will have to match the type of message that `Http.expectWhatever` wants,
 which we can see from the type signature of `Http.expectWhatever`:

```elm
expectWhatever : (Result Error () -> msg) -> Expect msg
```

`(Result Error () -> msg)` means a function that takes a `Result Error ()` as an argument,
and returns a message.
So if we create a message `SavingCommentFinished` that takes a `Result Error ()` as an argument,
`SavingCommentFinished` will be a constructor (a function) that takes one argument (`Result Error ()`),
and returns a `Msg`.

The `Error` type in question here is from the `Http` package
(you can see how it's defined [here](https://package.elm-lang.org/packages/elm/http/latest/Http#Error),
it's pretty simple).
So we will define our message by adding the following to our `Msg` type:

```elm
    | SavingCommentFinished (Result Http.Error ())
```

1. Add the new message `SavingCommentFinished` to the `Msg` type,
and add a case for the new message in the `update` function.
You can just return `( model, Cmd.none )` from `update` in that case.

2. Next, we can make the actual request, by replacing `Cmd.none` with the following,
when the "Post comment" button is clicked:
    ```elm
    Http.post
        { url = "/api/article/" ++ "dummy_id" ++ "/comments"
        , body = Http.emptyBody
        , expect = Http.expectWhatever SavingCommentFinished
        }
    ```

    If done correctly, you can now press the "Post comment" button in the browser,
    and you should se in the Elm debugger that you have recieved a message that looks something like this:
    ```
    SavingCommentFinished (Err (BadStatus 404))
    ```

    That is what we expect, since `dummy_id` isn't a real article ID,
    and the server therefore returns a status code of 404.

3. Let's change this, by using a real article ID!
`SuccessModel` has an `article` field,
every `Article` has an ID of type `ArticleId`,
and the `ArticleId` module has a `toString` function,
which we can use to get the ID of our article as a `String`.
Replace the string `"dummy_id"` in the URL with our actual ID.

    If successful, you will instead see that the server returned a `400` status code,
    resulting in the following in the Elm debugger:

    ```
    SavingCommentFinished (Err (BadStatus 400))
    ```

4. Next, we will need to include the actual comment text in request, instead of an empty body.
The `Http` module has a function for JSON bodys called `Http.jsonBody`,
with the following type signature:

    ```elm
    jsonBody : Json.Encode.Value -> Body
    ```

    For that function we need a `Json.Encode.Value` which is, as the name suggests,
    a JSON encoded value, using the `Json.Encode` module.
    Start by adding a JSON body of only `null` to the request,
    by changing the `body` field to the following:

    ```elm
    body = Http.jsonBody Json.Encode.null
    ```

    You might need to import the `Json.Encode` library, by adding the following line:

    ```elm
   import Json.Encode
   ```

    This request will still result in a status code of 400 from the server.

5. Since our request should actually be a JSON object (as described in the beginning of Task 2.3),
we can use the `Json.Encode.object` function, which has the following type signature:

    ```elm
    object: List (String, Value) -> Value
    ```

    Replace `Json.Encode.null` with a call to `Json.Encode.object`,
    with an empty list as the argument.

6. Next, we want to add the actual commentText to our request,
but right now we don't have access to it,
because we haven't done a case statement on the `NewCommentState` to get access to the String.
Add two case statements, one to get access to `SuccessModel`,
and another to check that we are in the `WritingComment` state,
and place the POST request in only that state.

    This has the added benefit of only allowing the user to send one request at a time,
    since a click on the button in the loading state won't result in an inadvertent request.

7. The `(String, Value)` tuples in the list in the type signature of `Json.Encode.object`
are the key and value pairs of the object.
We only need one field in our request,
so you can add the following tuple to the list:

    ```elm
    ("text", Json.Encode.string commentText)
    ```

    Make sure that you actually called the comment text `commentText`!

    If you try to push the button now, you should see the following in the Elm debugger:

    ```
    SavingCommentFinished (Ok ())
    ```

    Which means that our request actually succeeded! Congratulations!

## Task 2.4: Cleaning up the code for our request

Lastly in this task, we will clean up the code a bit.
Doing the POST request inline in the `update` function works,
but it got a bit messy.
We will extract the code as a function in an API module.

There is already a file called `Api.elm` in the `src` directory,
where we will move the code for our request.
We will start by copying the code we have written there, which won't compile.
We will then make small changes to get the app to a working state.


1. Create a function in `Api.elm` called `createCommentOnArticle`,
that doesn't take any arguments,
and without a type signature (for now),
and copy the `Http.post` function call as the body.
This won't compile, but that's okay.
We will fix one compilation error at a time.

2. The first compilation error is the easiest to fix:

    ```
    I cannot find a `Json.Encode.string` variable
    ```

    To fix this error, we just have to import `Json.Encode`

3. The second compilation error says that we don't have a `commentText` variable.
Add an argument to the function called `commentText` to fix this.

4. The next compilation error we want to tackle says that we don't have a `article` variable.
Now, we don't actually need the entire article,
so we could just add another string as an argument,
but that would make the function quite confusing,
since it wouldn't be clear which of the two `String` arguments was the articleId,
and which was the comment text.
We therefore add `articleId` as an argument, since it is of type `ArticleId` and not `String`.
Add the argument, and use it in the url.

5. The last compilation error is the trickiest, It says the following:

    ```
    I cannot find a `SavingCommentFinished` variant
    ```

    Now, you might think "why can't we just expose `Msg` from our article page, and import that?"
    And while that might seem natural,
    that would actually result in another compilation error,
    because it would cause a sircular dependency in our app
    (meaning that the article page imports APi, which imports article page, which imports API, and so on).
    But even if we _could_ do that, it wouldn't actually be such a good idea,
    because it would couple the function for creating a comment to the article page.
    That would mean that other modules couldn't really use that function,
    since it would always send a `SavingCommentFinished` message when finished.

    What we will do instead, is the same thing that the `Http` module does
    (and the `Html` module along with many others):
    we will take as an argument _any_ message, as long as it has the right type.
    And what is that type? It's:

    ```elm
    (Result Http.Error () -> msg)
    ```

    So, we will add another argument to our function, and just call it `msg`.
    These types of arguments are usually the first argument to a function.
    So your function declaration should now look like this:

    ```elm
    createCommentOnArticle msg commentText articleId =
    ```

    Also make sure to use the new `msg` argument, instead of `SavingCommentFinished`.

    Your app should now compile again!

6. Before actually using the function, we are going to add a type annotation to it.
Look at the other functions in the `Api` module, to try to add the correct type annotation.
You will know it is right if your code compiles.

7. To use the function,
we are going to have to expose it in the module declaration at the top of the file.
So add the function to the list of exposed functions there.

8. Lastly, back in `src/Page/Article.elm`,
replace the `Http.post` call with a call to `Api.createCommentOnArticle` with the proper arguments.

Your code should now compile, and if you try to click the button again, to post a comment,
you should see another `SavingCommentFinished (Ok ())` in the Elm debugger!

To double check that we actually end up sending a request, we can check the developer tools in the browser.
Right click the page in the browser,
and select "Inspect" in Chrome (or "Inspect element" in Firefox/Safari),
and go to the "Network" tab.
In the app, click the "Post" button again to see the request appear.
You can click on the request and select the "Headers" tab,
to see more info about it, like the URL and the request payload.
And, if you select the "Preview"/"Response" tab,
you can see what the browser returns as a response to our request.
Turns out, there are already a lot of comments on the article, that we don't display!

Next, we will get the comments from the server, and display them in our app!
