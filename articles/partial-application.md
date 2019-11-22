title: Partial Application
lead: When looking at a type signature of a function that takes more than one argument for the first time, it might seem strange that arguments are separated by arrows, instead of commas or space or something entirely different. Arrows are most often used to signify the return type of a function, so why is it used all over the place in the type signatures of functions in Elm?
author: Aksel Wester
---

To explain why Elm uses arrows instead of commas we can use the REPL with some of Elm's built-in functions.
We start by evaluating the function `repeat` in the `String` module:

```elm
> String.repeat
<function> : Int -> String -> String
```
We see that `String.repeat` is a function that expects two arguments: an `Int` (the number of times to repeat a `String`),
and a `String` to be repeated. We can call the function like this:

```elm
> String.repeat 3 "ho"
"hohoho" : String
```

Now we will try something that might just seem like a silly idea in other languages:

```elm
> String.repeat 3
<function> : String -> String
```

So what is happening here? Well we provide the function `repeat` with only one argument,
but instead of executing the function and failing (like we might expect from Javascript),
or simply complaining that the function was provided too few arguments (like we might see in languages like Java),
the Elm REPL says that this evaluates to a function that takes a `String`  as an argument and returns a `String`.

The feature of Elm on display here is called _partial application_.
It means that functions can be applied to only some of the arguments it expects,
and a new function will be returned expecting the remaining arguments.

We can actually do something similar in Javascript if we want, but it is much more of a hassle to write.
We can demonstrate with a function `add` that adds two numbers:

```javascript
function add(n) {
    return function(m) {
        return n + m;
    }
}
``` 

The function `add` returns another function, so to add 2 and 3, we would have to do it like this `add(2)(3)`.
Needless to say, this is a bit clunky,
so Javascript developers don't usually spend their days writing functions in this way.

In Elm, the same function would be written like this:

```elm
add : Int -> Int -> Int
add n m =
    n + m
``` 

and we would call it like this `add 2 3`. In other words, a completely ordinary Elm function.

## What's the big deal?

Okay, so why do we care that you can partially apply functions in Elm?
We care because a lot of functions in Elm take other functions as arguments,
and this allows us to write those functions in more a concise way that is easier to read.

Say, for instance, that we want to repeat the strings in a list.
Using `List.map` and `String.repeat`, we could do it like this, using a lambda function:

```elm
List.map (\element -> String.repeat 3 element) ["hi", "ha", "ho"]
```    

If we instead partially apply `String.repeat` we can write it like this:

```elm
List.map (String.repeat 3) ["hi", "ha", "ho"]
```    

`List.map` takes two arguments, a function `(a -> b)` and a `List a`, and returns another `List b`.
In our case, both of the type variables `a` and `b` are `String`, so we can rewrite the type signature as:

```elm
List.map : (String -> String) -> List String -> List String
```

Since the first argument is `(String -> String)`,
and we already saw that `String.repeat 3` evaluates to `(String -> String)`,
we can see that the types match up.

Partial application can also be used for the constructor of custom types.
For instance `Just` in the `Maybe` module, like this:

```elm
> List.map Just [1, 2, 3]
[Just 1, Just 2, Just 3] : List (Maybe Int)
```

Using partial application can make your code cleaner and more readable,
and when you grasp the concept of partial application, you start to see lots of places where you can use it. 
