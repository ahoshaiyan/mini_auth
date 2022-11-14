# MiniAuth

A small authenticated gem inspired by Laravel guards pattern.


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add mini_auth_rb

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install mini_auth_rb


## Guard Pattern

Authentication should be easy to use, implement and simple enough to be secure. Often unnecessary complexity can
lead to undesired security problems, and unfortunately a lot of Rails authentication libraries are built upon a lot
of layers and try to support different frameworks alongside Rails thus making them more complex and weird to deal with.

Here with `mini_auth_rb`, you will get the most simple infrastructure you need to deal with, i.e. authentication guards
and one helper middleware. You need to bring your own controller, views, password resets, etc.

Without further ado, let us understand what is a guard?

Imagine your self going to a party, and you are there at the location but outside. You notice that there is two doors,
one for party guests and another one for staff who are running things.

As a party guest, you will be asked to identify your self by the receptionist (our guard in this case) by showing your
invitation. Without a proper and valid invitation you will be simply denied access period.

As for staff, they have their own entrance, a backdoor. If they try to enter the building from the front door they will
be stopped and should go instead through the appropriate door.

Same goes for guests, they are not allowed through the back door.

I know this is confusing, by hold on a bit and everything should be clear.


## Our Sample Application

```text
If you are looking for setup instructions and already understand how the library work, you can skip to the next section.
```

We have a small web store, and it is divided into two sections (or routes), the store itself (guest area),
and a back-office where staff can supervise and manage the store.

Our `routes.rb` looks like this:

```ruby
Rails.application.routes.draw do
  # Guest Area
  resources :items
  resource :account
  post :logout, to: 'logout#perform'
  
  # Registration Help
  resource :login, only: [:new, :create]
  resource :registration, only: [:new, :create] 
  
  # Staff Area (back-office)
  namespace :staff do
    resources :items
    resources :orders
    resources :users
    resource :login, only: [:new, :create]
    resource :registration, only: [:new, :create]
  end
  
  root to: 'home#index'
end
```

Stop here for a moment and think how are you going to solve the issue of authenticating different kind of users (or entities).

Some will suggest that there should be a `User` model with some kind of column to identify the type of role, either
a user of staff.

Hmm, but how are we going to prevent users from entering back office. Easy! you say, use a before action that does a check.

Well buddy, let us stop here. We need a clear line between user and staff here, I can't just keep asking people at the
party are you a guest or a staff? I need a solid way to identify between them and know where every one should go.

Here is an idea, let's make all staff dress in a custom that makes it easy to tell them apart from guest and makes it
easy for our guards to stop anyone not authorized from entering the back-office and any other restricted areas.

We can introduce two models, a `Staff` and a `User` model. Our code should know exactly what type they are dealing with
and simple static analysis should let us know if something is wrong.


## Auth Configuration

To use MiniAuth in your project, you will need to create a new initializer file at `config/initializers/mini_auth.rb`,
and add the following content:

```ruby
# frozen_string_literal: true

# This middleware is used to remove any initialized guard related to the current request
# after it has been processed and response is generated.
Rails.application.config.middleware.use(MiniAuth::ResetGuardMiddleware)

ActiveSupport.on_load :after_initialize do
  routes = Rails.application.routes.url_helpers

  guards = [
    {
      name: :web,
      builder: -> (manager, name, request) {
        MiniAuth::SessionGuard.new(name, User, request, routes.login_path, 86400)
      }
    },
    {
      name: :staff,
      builder: -> (manager, name, request) {
        MiniAuth::SessionGuard.new(name, Staff, request, routes.staff_login_path, 3600)
      }
    }
  ]

  Rails.application.config.mini_auth = {
    default: :web,
    guards: guards.freeze
  }
end
```


## Guarding Controllers

Guards work at the controller level by leveraging the `before_action` feature in Rails.

To use guard throughout your application, add the following concern to your `ApplicationController` class:

```ruby
class ApplicationController < ActionController::Base
  include MiniAuth::Guarded
  
  # ... other stuff here
end
```

Now we can simply protect or guard a controller or specific action as follows:

Here is an example for users:

```ruby
class AccountController < ApplicationController
  auth_requests! :web
  
  def index
    # current_user.is_a?(User) #=> true
  end
  
  def update
    # This is just an example
    current_user.update!(user_update_params)
  end
  
  def deactivate
    
  end
end
```

Here is an example for staff:

```ruby
class Staff::UsersController < ApplicationController
  auth_requests! :staff, only: :index
  
  def index
    # current_user.is_a?(Staff) #=> true
  end
end
```

We can also prevent authenticated users from entering a specific controller:


```ruby
class LoginController < ApplicationController
  guest_only! :web

  def new
    # current_user.nil? #=> true
  end

  def create
    # ...
  end
end
```

## The Guard Class

Have a look at [guard.rb](lib/mini_auth/guard.rb), it defines an interface that dictates how the process
of authentication works.

Whenever a request is made to a guarded controller, the `user` method will be called and it should return an instance
of the current entity or `nil` if the request is not authenticated.

For example, in a typical web application, the `SessionGuard` will look for a specific key within the current Rails session,
and try to match it against a record in the database.

Another example is the `ApiGuard`, it will read a `Bearer` token from the current request and find the user related to it.

The `SessionGuard` can be considered a stateful guard as it depends on the current state of the session and provides
the `attempt` and `login` methods to set the current user of the session.


## SessionGuard



## ApiGuard


## Your Own Guard


### How it Works?


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
