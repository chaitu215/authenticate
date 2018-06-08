# Authenticate Changelog


## [0.7.3] - June 7, 2018

### Support for rails 5.2
- added rails 5.2 support to gemspec
- added rails 5.2 to Appraisals, .travis.yml, gemfiles
- added `sqlite3.represent_boolean_as_integer = true` to dummy application config 
- bumped authenticate version
- update request specs, looks for 302 after login
- added build and release tasks to Rakefile

[0.7.3]: https://github.com/tomichj/authenticate/compare/v0.7.2...v0.7.3


## [0.7.2] - June 22, 2017

### API change
- removed new_users_path, sign_up_path remains

### New Feature
- added allow_sign_up flag to install generator 

[0.7.2]: https://github.com/tomichj/authenticate/compare/v0.7.1...v0.7.2


## [0.7.1] - June 22, 2017

### Fixed
- routes respects config.allow_sign_up? and shuts off /sign_up
- removed spurious output from install generator

[0.7.1]: https://github.com/tomichj/authenticate/compare/v0.7.0...v0.7.1


## [0.7.0] - May 25, 2017

### API Changes
- controller#require_authentication is deprecated, use controller#require_login
- controller#authenticated? is deprecated, use controller#logged_in? 
- added controller#logged_out?
 `authenticated?` and `required_authentication` will be removed in a future release.

### Test support
- Added login_as via middleware for feature/integration/system tests.
- added rspec helpers for view and controller tests
- added test-unit helpers for controller/view tests

### Internal changes - will not affect normal apps
- Session#initialize(request, cookies) is now Session#initialize(request)
- Session API changes, #authenticated? renamed #logged_in?

[0.7.0]: https://github.com/tomichj/authenticate/compare/v0.6.1...v0.7.0


## [0.6.1] - May 16, 2017

### Fixed
- install migrations now correctly support rails 4.2.x and rails 5.x.

[0.6.1]: https://github.com/tomichj/authenticate/compare/v0.6.0...v0.6.1



## [0.6.0] - May 16, 2017

### Security
- Prevent [password reset token leakage] through HTTP referrer across domains. password#edit removes the password 
  reset token from the url, sets it into the user's session (typically a cookie), and redirects to password#url 
  without the token in the url.

- Prevent [session fixation] attacks by rotating CSRF tokens on sign-in by setting
  `Authentication.configuration.rotate_csrf_on_sign_in` to `true`. This is recommended for
  all applications. The setting defaults to `false` in this release, but will default to `true`
  in a future release.

### Fixed
- Location to return to after login is now written to session. Was previously written explicitly to a cookie.
- Most controller tests rewritten as feature and request tests.

[password reset token leakage]: https://security.stackexchange.com/questions/69074/how-to-implement-password-reset-functionality-without-becoming-susceptible-to-cr
[session fixation]: http://guides.rubyonrails.org/security.html#session-fixation
[0.6.0]: https://github.com/tomichj/authenticate/compare/v0.5.0...v0.6.0



## [0.5.0] - March 26, 2017oh

### Support for rails 5.1.

[0.5.0]: https://github.com/tomichj/authenticate/compare/v0.4.0...v0.5.0



## [0.4.0] - June 2, 2016

### Fixed
- Install generator User:  ActiveRecord::Base for Rails 4 apps, ApplicationRecord for rails 5 (issue #2).

[0.4.0]: https://github.com/tomichj/authenticate/compare/v0.3.3...v0.4.0



## [0.3.3] - April 29, 2016

- Password change uses active record's dirty bit to detect that password was updated. 
- password_updated attribute removed.
- spec_helper now calls ActiveRecord::Migration.maintain_test_schema! (or check_pending!) to handle dummy test db.
- Added CodeClimate config.

[0.3.3]: https://github.com/tomichj/authenticate/compare/v0.3.2...v0.3.3



## [0.3.2] - April 28, 2016

- Error now raised if User model is missing required attributes.
- All code now conforms to a rubocode profile.

[0.3.2]: https://github.com/tomichj/authenticate/compare/v0.3.1...v0.3.2



## [0.3.1] - March 10, 2016

- User controller now allows arbitrary parameters without having to explicitly declare
  them. Still requires email and password.
- Mailer now checks for mail.respond_to?(:deliver_later) rather than rails version, to decide deliver vs deliver_later.
- Removed unused user_id_parameter config method.

[0.3.1]: https://github.com/tomichj/authenticate/compare/v0.3.0...v0.3.1



## [0.3.0] - February 24, 2016

- Moved normalize_email and find_normalized_email methods to base User module.
- Added full suite of controller and feature tests.

### Fixes
- failed login count fix was off by one.
- password validation now done only in correct circumstances

[0.3.0]: https://github.com/tomichj/authenticate/compare/v0.2.2...v0.3.0



## [0.2.3] - February 13, 2016

- Small bugfix for :username authentication.
- Improved documentation, started adding wiki pages.

[0.2.3]: https://github.com/tomichj/authenticate/compare/v0.2.2...v0.2.3



## [0.2.2] - February 9, 2016

- Password length range requirements added, defaults to 8..128.
- Generators and app now respect model class more completely, including in routes.

[0.2.2]: https://github.com/tomichj/authenticate/compare/v0.2.1...v0.2.2



## [0.2.1] - February 9, 2016

- Fixed potential password_reset nil pointer.
- Continued adding I18n support.
- Minor documentation improvements.

[0.2.1]: https://github.com/tomichj/authenticate/compare/v0.2.0...v0.2.1



## [0.2.0] - February 2, 2016

- Added app/ including controllers, views, routes, mailers.

[0.2.0]: https://github.com/tomichj/authenticate/compare/v0.1.0...v0.2.0



## 0.1.0 - January 23, 2016

- Initial Release, barely functioning

