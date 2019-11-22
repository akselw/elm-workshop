title: Modelling in Elm
lead: Using custom types
author: Aksel Wester
---

Elm's type system is one of the greatest things about Elm, and it is both more useful and more powerful than the type systems of languages like Java or C#.
If we use the type system correctly, we can be certain that our code only ever ends up in "valid" situations.
Coupled with the tremendously helpful compiler, making robust programs feels fun and rewarding.
But to get the most help from the compiler, we have to make sure that our types
match up with what we are trying to do.

As an example, we can try to model a user of our application.
Let's say the user is either logged in with a username,
or not logged in.
And if the user is logged in they might be an administrator,
which would have some special priviliges in our app.

If we were to model the user type with a record, we might end up with something like this:

```elm
type alias User =
   { loggedIn : Bool
   , username : Maybe String
   , administrator : Bool
   }
```

We say that a `User` is a record with three fields:
a `loggedIn` field which is a boolean,
an `administrator` field, which is also a boolean,
and a `username` field, which is a [`Maybe String`](https://package.elm-lang.org/packages/elm/core/latest/Maybe),
meaning that the `String` might be there, or it might not (for instance if the user is not logged in).

At first glance this looks perfectly reasonable,
but when we look at what possible states this can result in, we see that modelling a user in this way
can result in unintended states, that we don't want.
The following example would, for instance, be perfectly valid, according to the type system:

```elm
user =
   { loggedIn = False
   , username = Nothing
   , administrator = True
   }
```

Here we have a user that is not logged in, does not have a username, but _is_ an administrator.
How does that work?
Well, it probably shouldn't, but at this point it's perfectly valid code.

Similarly, this user would also compile just fine:

```elm
user =
   { loggedIn = False
   , username = Just "evan"
   , administrator = False
   }
```

...but probably shouldn't,
since it doesn't really make sense to have a username if our user is not logged in.

Enter the _custom type_.

## Custom types

One of the most satisfying things about Elm to me, is the custom type.
A custom type is defined using the key word `type`, like this:

```elm
type MyCustomType
   = OptionA
   | OptionB
```

This creates a type that _has to_  be either `OptionA` or `OptionB`.
No `null`, no `undefined`, no anything else: those are the only two options for this particular type.
But `MyCustomType` is basically just a `Bool`, since we have a type that is one of two options,
`OptionA` or `OptionB`, just like `True` or `False`.
And in fact, that is exactly what `Bool` is in Elm, a custom type that is either `True` or `False`:

```elm
type Bool
   = True
   | False
```

The real usefulness with the custom type in Elm is that (1) your custom types can have however many options you want,
and (2) each option in a custom type can have values associated with it.
We can look at point no. 2 first.

Returning to our `User` example, we can now try to model the `User` type using a custom type:

```elm
type User
   = Administrator String
   | LoggedIn String
   | Guest
```

This means that if we have a `User` that is either an `Administrator`, `LoggedIn` or a `Guest` (not logged in).
In the first two options, when the user is logged in,
we also have a `String` , which is the username.
To check which type of `User` we have, or to get access to the username, we use a `case` expression:

```elm
getUsername : User -> String
getUsername user =
   case user of
       Administrator username ->
           username

       LoggedIn username ->
           username

       Guest ->
           "Guest"
```

In the code above we define a function `getUsername`, which takes a `User` and returns a `String`.
In the function body, we use a `case` expression to check which of the options of `User` the `user`
provided as an argument is.
In the branches for `Administrator` and `LoggedIn` we also get access to the `String` values associated
with each option, and we give them the variable name `username`,
which we then return.
In the branch for `Guest`, we don't have any username to get access to,
so we just return the hardcoded string `"Guest"`.

Using a `case` expression is the _only_ way to get access to the values associated with a specific custom type.
This also means that we always have to take every option into account,
because if we don't our app won't compile!
For instance, if we had forgotten the case for `Guest` in the function above,
the compiler would have given us the following error:

[bilde]

This gives us the certainty that all possible states are accounted for, when our app compiles.
This is an experience I have never had in any other programming language!

The beauty of modelling our state with custom types is that we can put restrictions in the type system that aren't possible to model with just records.
Custom types are one of the tools we can use to make "impossible states impossible",
as Richard Feldman explains in his [Elm Conf talk from 2016](https://youtu.be/IcgmSRJHu_8).

We will examine custom types further as we inch closer to Christmas,
and we will explore other ways of modelling our application states
to be as precise and easy to work with as possible.
In the mean time you can check out custom types in [the official guide.](https://guide.elm-lang.org/types/custom_types.html)
