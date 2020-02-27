![](https://github.com/hasghari/conifer/workflows/Ruby/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/f02c1de9e9d7dbfa5800/maintainability)](https://codeclimate.com/github/hasghari/conifer/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f02c1de9e9d7dbfa5800/test_coverage)](https://codeclimate.com/github/hasghari/conifer/test_coverage)

# Conifer

Conifer allows you to easily manage YAML configuration files and import them into your Ruby objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'conifer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install conifer

## Usage

You can include the `Conifer` module in any class or module and specify the YAML file you want to import by calling the
`conifer` method:

```ruby
class Config
  include Conifer

  conifer :config
end
```

By default, this will look for a file called `config.yml` in the same directory where the `Config` class is defined.
If no such file is found, it will look for that file in the parent directory. It will continue to traverse the ancestry
tree until it finds that file. If the file is not found, it will raise a `Conifer::File::NotFoundError` error.

With the following `config.yml` file defined in the same directory as the source file for `Config`:

```yaml
aws:
  access_key_id: <%= ENV.fetch('AWS_ACCESS_KEY_ID', 'my-access-key-id') %>
  bucket: atlantis
```

You may access the values using a method that defaults to the same name as your YAML file:

```ruby
object = Config.new
object.config['aws.access_key_id'] #=> my-access-key-id
object.config['aws.bucket'] #=> atlantis
```

The `conifer` method accepts several optional keyword arguments:

- `dir`: This option overrides the default location where the YAML file is expected to reside.
- `method`: This option overrides the default method name that is defined on the class or module. The method name defaults to the name of the YAML file.
    ```ruby
    class Config
      include Conifer

      conifer :config, method: :foobar
    end
    ```

    ```ruby
    Config.new.foobar['aws.bucket'] #=> atlantis
    ```
- `prefix`: This is a string that will be prepended to the lookup key. This is especially useful in Rails where you would like to have different values per environment.
    ```ruby
    class Config
      include Conifer

      conifer :config, prefix: Rails.env
    end
    ```

    With the following `config.yml` file:

    ```yaml
    development:
      aws:
        bucket: atlantis-development

    production:
      aws:
        bucket: atlantis-production
    ```

    You can lookup the values the same as before:

    ```ruby
    Rails.env #=> development
    Config.new.config['aws.bucket'] #=> atlantis-development
    ```
- `singleton`: This is `false` by default. When set to `true`, the method will be defined at the class scope instead of the instance scope.
    ```ruby
    class Config
      include Conifer

      conifer :config, singleton: true
    end
    ```

    ```ruby
    Config.config['aws.bucket'] #=> atlantis
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hasghari/conifer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Conifer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/conifer/blob/master/CODE_OF_CONDUCT.md).
