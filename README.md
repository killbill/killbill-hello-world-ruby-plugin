killbill-hello-world-ruby-plugin
================================

Hello World Kill Bill plugin in Ruby.

To package your app for Kill Bill, run:

```
# Use JRuby to avoid building native extensions
rvm use jruby
bundle install
jbundle install
rake killbill:clean
rake build
rake killbill:package
```

The artifact is available under the pkg/ directory.

Tests
-----

You need JRuby to run the test suite.

```
rvm use jruby
bundle install
jbundle install
rake
```