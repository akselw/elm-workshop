# 4-hiding-complexity

title: Hiding Complexity lead: With opaque types author: Aksel Wester links:

* title: Modelling using custom types

  link: [https://elm.christmas/2018/3](https://elm.christmas/2018/3)

* title: Elm.christmas article about the module system

  link: [https://elm.christmas/2018/14](https://elm.christmas/2018/14)

* title: Browser module

  link: [https://package.elm-lang.org/packages/elm/browser/latest/Browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser)

* title: Make Data Structures

  link: [https://youtu.be/x1FU3e0sT1I](https://youtu.be/x1FU3e0sT1I)

When making larger applications we tend to get some types, and bits of code, that are used all over our application. In the article about [modelling using custom types](https://elm.christmas/2018/3) we created a custom type `User`, with three constructors \(the three different options the custom type could be\):

```text
type User
    = Administrator String
    | LoggedIn String
    | Guest
```

This is great because we could ensure that we couldn't get into a state we didn't expect being in, like the user not being `loggedIn`, but still having a `username`.

If we had constructed a large application where we used this type, we would probably have used the `User` type all over the place in our code. We could have done this by exposing the type and its constructors from a module, like this, as we saw in [the article about the module system](https://elm.christmas/2018/14):

```text
module User exposing (User(..))
```

Exposing constructors \(with the `(..)` after the type name\) makes it possible to use a `case` expression on the type, to figure out which of the three options the user is. But doing this also creates a dependency upon the implementation of `User`. Or in other words, it causes us to have to refactor all the places in our application that use a `case` expression on the `User` type, if we later want to change something about the `User` type.

Now, Elm makes this refactoring quite easy, since the compiler will helpfully point out all the places in our code that need to change. But wouldn't it be a lot easier if we could change something about the `User` type, without having to change any of the places using the type?

To see how we could do this, we will start by looking at the `User` module in its entirety:

```text
module User exposing (User(..))

type User
    = Administrator String
    | LoggedIn String
    | Guest
```

Let's say we want to change the `User` type, by adding a full name, in addition to the username that we already have in the type \(a username would be something like "akselw", while the full name would be "Aksel Wester"\). We could either just add another `String` argument to `Administrator` and `LoggedIn`, but that would make it hard to keep track of which `String` is what, so instead we will create a record:

```text
module User exposing (User(..))

type alias LoggedInInfo =
    { username: String
    , fullName: String
    }

type User
    = Administrator LoggedInInfo
    | LoggedIn LoggedInInfo
    | Guest
```

But having done this we would now get a compiler error all the places using the `User` type in a `case` expression, like this:

\[bilde\]

Actually we would get _a lot_ of these errors, depending on the the size of our app.

So how could we have solved this?

## Opaque types

An opaque type is a type where the implementation is hidden. In Elm we can create an opaque type by removing the `(..)` from the first line in our module, like this:

```text
module User exposing (User)
```

Now, we are only exposing the _type_ `User`, not the constructors, so others can't create their own `User` values. So, for instance, trying to create a `User` with the `Guest` constructor would not compile, and `case` expressions will also no longer compile.

But we still want other parts of our application to have access to the information in a `User`, so how will we accomplish that? We can accomplish that through helper functions that we expose from the module. These helper functions can take a `User` as an argument, and return something about that `User`. We will show this by writing two functions, `username` and `isAdministrator`:

```text
module User exposing (User, username, isAdministrator)

type alias LoggedInInfo =
    { username: String
    , fullName: String
    }

type User
    = Administrator LoggedInInfo
    | LoggedIn LoggedInInfo
    | Guest

username : User -> Maybe String
username user =
    case user of
        Administrator { username } ->
            Just username

        LoggedIn { username } ->
            Just username

        Guest ->
            Nothing


isAdministrator : User -> Bool
isAdministrator user =
    case user of
        Administrator _ ->
            True

        LoggedIn _ ->
            False

        Guest ->
            False
```

In the function `username`, we use a `case` expression on the `User` and return a `Just` of the username if there is a username there, and `Nothing` is there is no username \(the `{ username }` is inline destructuring of the `LoggedInInfo` record, which is quite handy\). In the function `isAdministrator`, we simply return `True` if the `User` is an administrator, and otherwise we return `False`. The key here is that both of these functions is exposed from the module, but not the underlying implementation of `User` and the functions!

To create a new `User`, we might make a function called `init`. Or maybe we could just create a decoder, so the only way to make a `User` is to get one from the server. It's really up to us.

It might seem like a lot of overhead to create types like this, but the upfront cost isn't really _that high_, compared to the benefits it gives us in refactoring down the line. If we had made our `User` module this way from the start, it would have been trivial to add another field to `LoggedInInfo`, to add another option to the `User` type, or even rewrite the entire type in some other way. As long as the API of our module remains the same \(the functions and types we expose\), we can change the implementation however we like!

Even though you might not have thought about it before, you have probably already used opaque types in you applications! `Program`, which is the return type of `Browser.sandbox`, `Browser.element` and so on, in the [`Browser` package](https://package.elm-lang.org/packages/elm/browser/latest/Browser) is an opaque type. We don't really now anything about the implementation, and we can't create our own programs except through the functions exposed by the `Browser` package. And that makes it possible for `Program` to change its entire implementation, without breaking any of our applications! The same is also true for a lot of other types in both `elm-core` and a lot of other packages.

For more on modelling and types, I would recommend Richard Feldman's 2018 talk from Elm Europe: [Make Data Structures](https://youtu.be/x1FU3e0sT1I), which is a great talk, and where I saw a lot of these concepts for the first time!

