# Teeplate

A Crystal library for rendering multiple template files.

[![Build Status](https://travis-ci.org/mosop/teeplate.svg?branch=master)](https://travis-ci.org/mosop/teeplate)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  teeplate:
    github: mosop/teeplate
```

## Supported Template Engines

* ECR

## Usage

```crystal
require "teeplate"
```

## Example

Let's make our `crystal init` template.

#### Template structure

* spec/
  * spec_helper.cr.ecr
  * {{file}}_spec.cr.ecr
* src/
  * {{file}}/
    * version.cr.ecr
  * {{file}}.cr.ecr
* .gitignore
* .travis.yml
* LICENSE.ecr
* README.md.ecr
* shard.yml.ecr

#### Template file example

```yaml
# shard.yml.ecr
name: <%= @file %>
version: 0.1.0

authors:
  - <%= @author %>

license: MIT
```

#### Template class definition

```crystal
class CrystalInitTemplate < Teeplate::FileTree
  directory "#{__DIR__}/path/to/template"

  @file : String
  @class : String
  @author : String
  @year : Int32

  def initialize(@file, @class, @author, @year)
  end
end
```

#### Here we go!

```crystal
CrystalInitTemplate.new("teeplate", "Teeplate", "mosop", 2016).render("/path/to/output")
```

#### Output structure

* spec/
  * spec_helper.cr
  * teeplate_spec.cr
* src/
  * teeplate/
    * version.cr
  * teeplate.cr
* .gitignore
* .travis.yml
* LICENSE
* README.md
* shard.yml

#### Output example

```yaml
# shard.yml
name: teeplate
version: 0.1.0

authors:
  - mosop

license: MIT
```

## Overwriting

### Forced

If a file already exists, Teeplate skips rendering the file. To force overwriting, set the `:force` option:

```crystal
class Template < Teeplate::FileTree
  directory "/path/to/template"

  @face : String

  def initialize(@face)
  end
end

Template.new(":)").render("/path/to/output")
Template.new(":(").render("/path/to/output", force: true) # files to be overwritten
Template.new(":P").render("/path/to/output") # nothing happens
```

### Interactive

If the `:interactive` option is true, Teeplate prompts us to select whether to overwrite an existing file.

```
shard.yml already exists...
overwrite(o)/keep(k)/diff(d)/overwrite all(a)/keep all(n) ?
```

## Want to Do

* Listing rendered files (colorized)

## Release Notes

* v0.2.0
  * (Breaking Change) FileTree#initialize does not receive an output directory. Instead, FileTree#render does.
  * Diff on overwriting confirmation
  * Overwrite All / Keep All on overwriting confirmation
* v0.1.3
  * :interactive option to select whether to overwrite existing files
* v0.1.2
  * :force option to overwrite output files if they exist

## Contributing

1. Fork it ( https://github.com/mosop/teeplate/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mosop](https://github.com/mosop) - creator, maintainer
