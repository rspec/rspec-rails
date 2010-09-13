## rspec-rails release history (incomplete)

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.0.beta.20...v2.0.0.beta.22)

* Enhancements
  * autotest mapping improvements (Andreas Neuhaus)

* Bug fixes
  * delegate flunk to assertion delegate

### 2.0.0.beta.20 / 2010-08-24

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.0.beta.19...v2.0.0.beta.20)

* Enhancements
  * infer controller and action path_params in view specs
  * more cucumber features (Justin Ko)
  * clean up spec helper (Andre Arko)
  * render views in controller specs if controller class is not
    ActionController::Base
  * routing specs can access named routes
  * add assign(name, value) to helper specs (Justin Ko)
  * stub_model supports primary keys other than id (Justin Ko)
  * encapsulate Test::Unit and/or MiniTest assertions in a separate object
  * support choice between Webrat/Capybara (Justin Ko)
    * removed hard dependency on Webrat
  * support specs for 'abstract' subclasses of ActionController::Base (Mike Gehard)
  * be_a_new matcher supports args (Justin Ko)

* Bug fixes
  * support T::U components in mailer and request specs (Brasten Sager)
