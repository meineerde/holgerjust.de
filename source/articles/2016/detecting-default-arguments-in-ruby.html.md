---
title: Detecting default arguments in Ruby
date: 2016-12-27 20:08 UTC
author: Holger Just
lang: :en
tags: Technology
cover: 2016/detecting-default-arguments-in-ruby/cover.jpg
cover_license: '[Cover Image](https://unsplash.com/photos/p3kpqGBRPok) by [Tim Mossholder](https://unsplash.com/@timmossholder), [CC Zero 1.0](https://unsplash.com/license)'
layout: post
---

When defining a method in Ruby, you can define default values for optional parameters. When calling the method, Ruby sets the default value to the local variable *as if* the user would have provided this argument. This automatism is really useful to support optional parameters with sensible defaults without having to think much about this. It even works exactly the same with the new keyword arguments introduced in Ruby 2.0.

READMORE

Given this method:

```ruby
def debug(required, optional = 'value')
  puts "required: #{required}"
  puts "optional: #{optional}"
end
```

When calling the method, you get the usual results:

```ruby
debug('foo')
# require: foo
# optional: value

debug('bar', 'overwritten')
# require: bar
# optional: overwritten
```

A commonly used default value for optional parameters is `nil`. You can however use any value you like, including the result of a method call. This works great most of the time. That is, well, until you really have to test if an argument was actually provided by the caller or not since any value (including `nil`) would be considered valid.

A real-world example of such a method is [`Hash#fetch`](https://ruby-doc.org/core/Hash.html#method-i-fetch). This method allows to fetch the value for a given key from a Hash object. If the key is in the hash, its value is returned. If the key could not be found however, the method will either return a given default value or raise an error if no default value was provided. Since any Ruby object including `false` or `nil` are potentially valid default values, we can't just define a static default value here:

```ruby
hash = {foo: :bar}
hash.fetch(:foo)
# => :bar
hash.fetch(:missing)
# => KeyError: key not found: :missing
hash.fetch(:missing, 'my default value')
# => "my default value"
hash.fetch(:missing, nil)
# => nil
```

Luckily, there are several idioms which allow to detect whether there was actually an argument passed to an optional parameter which I will describe below.

## A Special Flag Variable

The first and most self-contained option is to use a guard flag in the method definition.

```ruby
def with_flag(required, optional = omitted = true)
  puts "required: #{required}"
  puts "omitted: #{omitted.inspect}"

  if omitted
    puts 'no optional given'
  else
    puts "optional: #{optional}"
  end
end
```

Now when calling this method and actually passing a value to the `optional` parameter, it will be set normally. The default part, i.e. `omitted = true` will not be executed here. Instead, the `omitted` paremeter will be initialized with `nil`.

On the other hand, when omitting the argument and calling the method as `with_flag('value')`, the default part will be executed and `omitted` as well as `optional` will be set to `true`. This allows to determine whether an argument was passed by checking the `omitted` flag. If it is `nil`, an argument was passed. If it is the final default value (`true` in our example) it was however omitted:

```ruby
with_flag('foo')
# required: foo
# omitted: true
# no optional given

with_flag('foo', 'value')
# required: foo
# omitted: nil
# optional: value
```

## Special Default Value

Another option is to use a different special default value which we have determined to never represent a valid value. Again, this is only required if we can not come up with a "normal" default value like `nil`, `0` or an empty array or hash.

In our example, we define a constant called `UNDEFINED` with an empty Object instance and use it as a default value. Since the object is not equal to any other value, you can use it as a special flag to determine that no value was passed and just compare the argument to the same `UNDEFINED` object.

```ruby
UNDEFINED = Object.new
# => #<Object:0x007fd87284af38>

def with_value(required, optional = UNDEFINED)
  puts "required: #{required}"

  if optional.equal?(UNDEFINED)
    puts "no optional given: #{optional}"
  else
    puts "optional: #{optional}"
  end
end
```

When calling the method, the comparisons work as expected. As you can see, the default value is initialized with the `UNDEFINED` constant when not passing the optional argument and thus is considered to be omitted.

```ruby
with_value('bar')
# required: foo
# no optional given: #<Object:0x007fd87284af38>

with_value('foo', 'value')
# required: foo
# optional: value
```

## Using a Splatted Parameter

A third option is to use a splat parameter in the method's definition. This accepts an unlimited number of optional arguments and provides them to the method body in an array.

```ruby
def with_splat(*args)
  # Enforce the actually intended method interface by raising an error if too
  # many arguments were passed to the method.
  unless 1..2.cover?(args.size)
    raise ArgumentError, "wrong number of arguments (#{args.length} for 1..2)"
  end

  puts "required: #{args[0]}"
  if args.size == 1
    puts 'no optional given'
  else
    puts "optional: #{args[1]}"
  end
end
```

By inspecting the `args` array, we can test whether we got an `optional` argument or not. If the array is has exactly 1 element, no `optional` argument was passed. If it has 2 elements, we use the second one as our `optional` value.

This variant more or less resembles what Ruby itself does in its implementation of the [`Hash#fetch`](https://ruby-doc.org/core/Hash.html#method-i-fetch) method for example. Since the method is implemented in C, arguments are extracted and validated from the `ARGV` array passed to the method which resembles our `args` array.

## Which variant to use?

Which option to use depends a bit on which traits of the code should be emphasized.

The first option with the `omitted` flag can read a bit nicer in the method body and does not require the permanent allocation of an additional object to represent the empty default value. However, the code and its detailed semantics can be a bit surprising for people not accustomed to this pattern. Which can result in people misusing the method.

The second option with the special default value however is pretty clear and follows the common pattern of assigning a known default value to a parameter. By defining our own null value, we can elegantly work around the issue of `nil` being a valid intended value. However, we always need to be aware of the special null value and often have to handle it in special way to e.g. pass it as `nil` to other methods. Since this pattern should be used only if `nil` itself is not a suitable default value, this would be required anyways though.

The third option of using splat parameters looks rather simple from the outside and doesn't rely on static values or the intricacies of argument assignments in Ruby. However, it has the huge downside that the method interface isn't clearly defined anymore. Just from looking at the method definition, we can no longer see how many arguments the method accepts but have to look into the method body. We even have to rely on custom error handling to check the number of passed arguments.

As such, for one-off methods, the first option is quicker to write and has clear-enough semantics to experienced Ruby developers. The second option provides a more traditional method interface for the potential cost of a bit more checking in the method body. With a well-named default value, the intention becomes clear just from looking at the method definition. The third option however does not resemble idiomatic Ruby anymore but looks more like C or Perl where we have to deal with numeric indexes instead of well-named variables and arguments. as such, this option has a clear disadvantage to the others since it is much less intention-revealing.

With that in mind, which ever variant you use, try to use one of these methods consistently throughout your module to allow people reading your code to recognize the pattern and thus to reduce the cognitive load required to understand what the code does.

Most of the time, you should try to rely on "normal" default values. Using one of the techniques described in this article should generally be your last resort since they will never be as clear as a simple method definition with simple default values.

*Update 2016-12-28: After some discussion on [Facebook](https://www.facebook.com/holger.just.9/posts/1198815266853010) it became clear that the motivation for why you would need these techniques is not clearly described. As such, I have added the real-world example of `Hash#fetch`. I also added the third option of using a splatted parameter.*
