# Task 3 - Fetching comments from the server

As we saw at the end of the last task,
the server actually returned some comments as a response,
when we created a new comment.
What we didn't see is that the server also has an endpoint to fetch all the comments on an article.

In this task we will make a request to the endpoint when the page loads,
and display the comments on an article to the user.
We will also update the list of comments when the user posts a new comment.

## Task 3.1: Making a GET request

We start by preparing our model for the new state:

Similarly to the model for the entire page,
we will create a custom type representing the state of the comments we are fetching.
We could choose to do this in other ways, but we want to achieve the following things with our model:
- Represent that fetching the comments either is in progress, has failed or has succeeded.
- Allow for the page to display the article, regardless of whether fetching the comments failed.

Other priorities will result in another representation.

1. Create a new custom type in the page we have been working on (`src/Page/Article`),
with the following definition:

    ```elm
    type CommentsState
        = LoadingComments
        | FailureGettingComments Http.Error
        | SucceededGettingComments (List Comment)
    ```

    You will need to import the `Comment` type, using the following line:

    ```elm
    import Comment exposing (Comment)
    ```

2. Next, add a field `comments` to `SuccessModel`, with the type `CommentsState`,
and follow the compilation errors until your code compiles.

3. In this task we will save the view to the end, so we continue by making the request to the server.
To do this, we start by making another message, for when fetching the comments is done.
The message can be identical to `SavingCommentFinished`,
except that you call it `FetchingCommentsFinished`.
Add `FetchingCommentsFinished` to `Msg`,
and make the required changes to the `update` function.
You can start by returning `( model, Cmd.none )` from `update`.

4. Now that your code compiles with the new message,
we can handle the message a bit more correctly in `update`.
Instead of just returning directly `( model, Cmd.none )`,
add a case statement on `model` to check that we are in the `Success` state of the page.

5. Then add another case statement inside the `Success` case to check whether the `Result`
we got in the message was `Ok` or `Err`. Set the `comments` field in `SuccessModel` accordingly
(you can just hard code an empty list in the `Ok` case for now).

6. Next, we will create a function in the `Api` module,
similar to the `createCommentOnArticle` we added in Task 2.4.
Name the function `getComments` , with the following type signature:

    ```elm
    getComments : (Result Http.Error () -> msg) -> ArticleId -> Cmd msg
    ```

    And use the `Http.get` function to make the request,
    and the URL to the comment endpoint is `/api/article/{articleId}/comments`,
    where `{articleId}` is the article ID of the article you just fetched.

    `Http.get` is similar `Http.post`, except that it doesn't have a `body`.
    You can read it's documentation [here](https://package.elm-lang.org/packages/elm/http/latest/Http#get),
    and you can use `Http.expectWhatever`, like we did in `createCommentOnArticle`.

7. We will now use the function we just created,
and we are going to make the request for comments when the `update` function
receives the message `FetchedArticle`.
Replace `Cmd.none` with the function call to `getComments` in the case for `FetchedArticle`.

In the browser, you should now see that the app makes a request to the comments endpoint.
You can see it in both the Elm debugger, and in the Network tab in the browser.

Note: This isn't the most efficient place to make the request,
since it will make the page wait for the article response before fetching the comments,
instead of doing the two request simultaneously.
In an optional task later,
you can try to change the app to handle making the requests at the same time.
But for now, we will go ahead with this strategy.

## Task 3.2: Decoding the comment response

As you can see in the browser,
the app now make a request to the comments endpoint,
and the response will look something like this (if you are on the "Modelling in Elm" page):

```json
[
  {
    "id": "q6dkYsTwdX",
    "username": "User 1",
    "text": "Functional programming SUXXX!"
  },
  {
    "id": "3ABrq4hXB_",
    "username": "User 2",
    "text": "No, you suck!!"
  },
  {
    "id": "keJKsI_jHl",
    "username": "User 3",
    "text": "I like him!"
  },
  {
    "id": "5OOsLzU_mw",
    "username": "User 4",
    "text": "I agree"
  },
  {
    "id": "LQb3OY4w19",
    "username": "User 5",
    "text": "I like modifying global variables 😊"
  }
]
```

We see that the endpoint returns a list of comments,
and that each comment has a three fields: `id`, `username`, and `text`,
all of with are strings.

To get access to these comments, we are going to have to decode them.
Simply put, decoding is Elm's way of guaranteeing that the JSON data we get from a server
is actually in the shape that we expect.

To decode the list of comments,
we are first going to have to make a decoder for the `Comment` type.
`Comment` is already defined in the `Comment` module in the file `src/Comment.elm`,
where you can take a look at it.

We can see that a `Comment` is a one-constructor union type, with three fields:
`id`, `username`, and `text`,
the first of which is of type `CommentId`,
while the remaining two are of type `String`.

This lines up quite well with what we are seeing in the response from the server,
except that the `id` field is a `CommentId`.
But actually, we don't have to decode every field we receive in a JSON object,
so we can start by removing the `id` field, to make our job a bit easier.

1. Remove the `id` field from the `CommentInfo` record.

2. To make a decoder for `Comment`, we are going to need a couple of packages,
so import add the following two lines to the imports:

    ```elm
    import Json.Decode exposing (Decoder)
    import Json.Decode.Pipeline exposing (optional, required)
    ```

    The decoder we are going to make, is going to have the type signature `Decoder Comment`.
    A decoder is sort of like a recipe for how the JSON should look.
    It is not function.
    But before we make our `Comment` decoder, we are going to make a decoder for `CommentInfo`.

3. Paste in the following code at the bottom of the file:

    ```elm
    commentInfoDecoder : Decoder CommentInfo
    commentInfoDecoder =
        Json.Decode.succeed CommentInfo
            |> required "text" Json.Decode.string
            |> required "username" Json.Decode.string
    ```

    Note: This isn't very easy to understand the first time you see it,
    and you really don't need to understand what's going on here to continue with the tasks.
    So read the brief explanation below, and move on to the next task.

    The code above uses the fact that type aliases for records automatically get
    a constructor of the same name as the type alias (`CommentInfo` in this case),
    where the arguments to the constructor are in the same order as the fields in the type alias.
    So the constructor called `CommentInfo` is just a function with the type signature:

    ```elm
    CommentInfo: String -> String -> CommentInfo
    ```

    The `required` lines below then pick out the values from the fields in the JSON object
    called "text" and "username", respectively, and decode the values in the those fields as strings
    (that's the `Json.Decode.string` part).
    The two resulting strings are then passed to the `CommentInfo` constructor in the order they are in,
    and the result is a `Decoder CommentInfo`.

    This is a simplefied explanation, so if you're thinking "that's not entirely correct",
    then you are right.
    But it is sufficient for now.

4.  We now have a `Decoder CommentInfo`, but what we ultimately need is a `Decoder Comment`.
To get that we are going to use [`Json.Decode.map`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#map).
`map` has the following type signature:

    ```elm
    map : (a -> value) -> Decoder a -> Decoder value
    ```

    In our case, we want to end up with a `Decoder Comment`,
    so `value` in the type signature is our `Comment`.
    `a` in this type signature is going to be our `CommentInfo`,
    since that is the decoder that we already have.
    If we write out the type signature again using our types, we get the following type signature:

    ```elm
    map : (CommentInfo -> Comment) -> Decoder CommentInfo -> Decoder Comment
    ```

    The second argument to `map` is going to be `commentInfoDecoder`,
    so what we need is the first argument,
    a function that takes a `CommentInfo` as an argument and returns a `Comment`.
    And actually, the one constructor in the `Comment` type is the function.
    It takes one argument, which is a `CommentInfo`, and returns a `Comment`.

    Given all that, we can add the following decoder for `Comment`:

    ```elm
    decoder : Decoder Comment
    decoder =
        Json.Decode.map Comment commentInfoDecoder
    ```

5. To use the decoder outside the `Comment` module, we are going to have to expose it.
Add `decoder` to the list exposed by the `Comment` module.

    Next, we are going to actually use the decoder to get the comments
    that the comments endpoint returns.

6. In the `Api` module, in the `getComments` function,
replace the call to `Http.expectWhatever` with the following line
(your code won't compile anymore, but we will fix that in the next steps):

    ```elm
    Http.expectJson msg (Json.Decode.list Comment.decoder)
    ```

    This line is saying that we no longer don't care about what the server returns,
    we now expect the endpoint to return JSON.
    We also say that the JSON should be decoded with decoder defined as `Json.Decode.list Comment.decoder`.
    `Comment.decoder` is the decoder we just made,
    and `Json.Decode.list` is a way to make a decoder for a list of a certain type.
    The decoder we pass to `expectJson` is therefore of type `Decoder (List Comment)`
    which is what we actually expect the endpoint to return.

7. The compilation error we now get,
says that the second argument to `expectJson` is not what the compiler expects.
However, the second argument (the decoder) is exactly what we want to pass to `expectJson`.
The thing we actually want to change is the type of the `msg` argument.
Change the type of the first argument, in the type signature of `getComments` to the following
(this will result in another compilation error):

    ```elm
    (Result Http.Error (List Comment) -> msg)
    ```

    We have now changed what type of message the `getComments` function accepts,
    since a successful call to the comments endpoint now results in a list of comments.

8. The compiler still complains, but this time the compilation error is in `src/Page/Article`,
since we are now calling `getComments` with the wrong first argument.
Fix this error by changing `FetchingCommentsFinished` in `Msg` to be of the type that
`getComments` expects.

    After fixing this, your code should compile.
    And if you check the Elm debugger in the browser,
    you will see that you actually receive a message with a list of comments!

9. You can now change the hard coding we did earlier in the `FetchingCommentsFinished` case
in `update`, so that we put the actual list of comments in the model,
instead of always using the empty list.

If you check the Elm debugger in the browser now,
you should see an actual list of comments in the model after the comments are finished loading.


## Task 3.3: A view for the comments

```elm
    div [ class "comment-section" ]
        [ h2 []
            [ text "3 comments"
            ]
        , div [ class "comments" ]
            [ div [ class "comment" ]
                [ div [ class "comment-username" ]
                    [ text "User 1" ]
                , div [ class "comment-text" ]
                    [ text "Text of the first comment" ]
                ]
            , div [ class "comment" ]
                [ div [ class "comment-username" ]
                    [ text "User 2" ]
                , div [ class "comment-text" ]
                    [ text "Text of the second comment" ]
                ]
            ]
        , viewWriteComment model
        ]
```

## Task 3.4: Updating the list of comments after a post

You can use the response from the POST request, to update the model.

## Task 3.5: Nested comments

The comments you get in the response when posting a comment are nested:
each comment has a field `comments`, which is a new list of comments.
Use the endpoint ```/api/article/{articleId}/nestedComments```,
in `Api.getComments` to get nested comments.
Decode the comments with subcomments.
