# Kristin

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'kristin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kristin

## Usage

You need to install [pdf2htmlEX](https://github.com/coolwanglu/pdf2htmlEX) on your system to use this gem.

```ruby
require 'kristin'

# Converts document.pdf to document.html
# This requires that the pdf2htmlEX command is present in your PATH.
Kristin.convert('document.pdf', 'document.html')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
