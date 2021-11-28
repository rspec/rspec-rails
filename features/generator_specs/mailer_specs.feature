Feature: Mailer generator spec

    Scenario: Mailer generator
        When I run `bundle exec rails generate mailer posts index show`
        Then the features should pass
        Then the output should contain:
          """
                create  app/mailers/posts_mailer.rb
                invoke  erb
                create    app/views/posts_mailer
                create    app/views/posts_mailer/index.text.erb
                create    app/views/posts_mailer/index.html.erb
                create    app/views/posts_mailer/show.text.erb
                create    app/views/posts_mailer/show.html.erb
                invoke  rspec
                create    spec/mailers/posts_spec.rb
                create    spec/fixtures/posts/index
                create    spec/fixtures/posts/show
                create    spec/mailers/previews/posts_preview.rb
          """

    Scenario: Mailer generator with customized `default-path`
        Given a file named ".rspec" with:
          """
          --default-path behaviour
          """
        And I run `bundle exec rails generate mailer posts index show`
        Then the features should pass
        Then the output should contain:
          """
                create  app/mailers/posts_mailer.rb
                invoke  erb
                create    app/views/posts_mailer
                create    app/views/posts_mailer/index.text.erb
                create    app/views/posts_mailer/index.html.erb
                create    app/views/posts_mailer/show.text.erb
                create    app/views/posts_mailer/show.html.erb
                invoke  rspec
                create    behaviour/mailers/posts_spec.rb
                create    behaviour/fixtures/posts/index
                create    behaviour/fixtures/posts/show
                create    behaviour/mailers/previews/posts_preview.rb
          """
