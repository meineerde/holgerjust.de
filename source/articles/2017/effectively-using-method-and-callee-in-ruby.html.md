---
title: Effectively using __method__ and __callee__ in Ruby
date: 2017-02-19
author: Holger Just
lang: :en
tags: Technology
cover: 2017/effectively-using-method-and-callee-in-ruby/cover.jpg
cover_license: '[Cover Image](https://unsplash.com/photos/uJU8znjgc1M) by [Gabby Orcutt](https://unsplash.com/@monroefiles), [CC Zero 1.0](https://unsplash.com/license)'
layout: post
---

Ruby provides many useful methods out of the box which allows for some very effective programming techniques. Today, we are taking a look at the [`__method__`](https://ruby-doc.org/core/Kernel.html#method-i-__method__) and [`__callee__`](https://ruby-doc.org/core/Kernel.html#method-i-__callee__) helper methods and how they can help us produce [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) code.

READMORE

Generally, both methods return the name of the currently running method as a Symbol. Using these methods, we can access the current method name without requiring us to duplicate the name in our code.

Now let's have a look at them in action. Consider the following example where we create a `Greeter` class which allows us to give personalized greetings:

```ruby
class Greeter
  def initialize(name)
    @name = name
  end

  def greetings
    "#{__method__.to_s.capitalize}, #{@name}!"
  end
end

greeter = Greeter.new('Ben')
greeter.greetings
# => "Greetings, Ben!"
```

As you can see, using the `__method__` helper we don't have to duplicate the name of the method in our code, thus keeping it DRY. In case we later decide to change the formality of the greeting and thus changing the method name, we wouldn't also have to remember to change the method body to return the new greeting.

This with working and our software starting to get popular all over the world, we might decide to introduce a more familiar way to greet people using different localizations. If we are in Australia, people might prefer to use

> Oi, Mick!

while in Sweden, it might be more appropriate to use

> Hej, Anja!

The first approach to implement this could be to add multiple new independent methods, one for each greeting variant. However, this would quickly get out of hand and would effectively duplicate lots of code.

Since we are already using `__method__` in our implementation, we could try to leverage this and use aliases instead.

```ruby
class Greeter
  def initialize(name)
    @name = name
  end

  def greetings
    "#{__method__.to_s.capitalize}, #{@name}!"
  end
  alias oi greetings
  alias hej greetings
end
```

Now, when calling one of the alias methods, it turns out that unfortunately (for our use-case) `__method__` always returns the name of the actual method, completely ignoring the alias we used:

```ruby
Greeter.new('Mick').oi
# => "Greetings, Mick!"

Greeter.new('Anja').hej
# => "Greetings, Anja!"
```

Fortunately, there is a very similar helper method named `__callee__` which helps us solve our use-case.

```ruby
class Greeter
  def initialize(name)
    @name = name
  end

  def greetings
    "#{__callee__.to_s.capitalize}, #{@name}!"
  end
  alias oi greetings
  alias hej greetings
end

Greeter.new('friend').greetings
# => "Greetings, friend!"

Greeter.new('Mick').oi
# => "Oi, Mick!"

Greeter.new('Anja').hej
# => "Hej, Anja!"
```

Using the `__callee__` helper, we can get the name of the current method exactly as it was called. For normal methods, this returns the same name as `__method__`. Once we use methods aliases however, the returned value differs since `__callee__` always returns the name of the method as we actually called it, whichever alias that might be.

Since both helper methods are provided by Ruby's [`Kernel`](https://ruby-doc.org/core/Kernel.html) module, they are directly available in about all Ruby objects. Using them, we can keep our code nice and DRY but still add new functionality with just one line of code without having to change any existing methods.
