# MiniAuth

A small authenticated gem inspired by Laravel's guards pattern.


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add mini_auth

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install mini_auth


## Usage

To use MiniAuth in your project, you will need to create a new initializer file at `config/initializers/mini_auth.rb`,
and add the following content:

```ruby
# frozen_string_literal: true

Rails.application.config.middleware.use(MiniAuth::ResetGuardMiddleware)

ActiveSupport.on_load :after_initialize do
  routes = Rails.application.routes.url_helpers

  guards = [
    {
      name: :web,
      builder: -> (manager, name, request) {
        MiniAuth::SessionGuard.new(name, User, request, routes.login_path, 86400)
      }
    }
  ]

  Rails.application.config.mini_auth = {
    default: :web,
    guards: guards.freeze
  }
end
```

Assuming you have an active record model called `User` and you have a route called `login`.


### How it Works?

// TODO: Explain what is a guard
// TODO: How SessionGuard works
// TODO: How ApiGuard works
// TODO: How to create a new guard


### Using Guards


### Session Guard


### API Guard


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
