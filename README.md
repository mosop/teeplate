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
  * .gitignore
  * spec_helper.cr.ecr
  * {{file}}_spec.cr.ecr
* src/
  * {{file}}/
    * version.cr.ecr
  * {{file}}.cr.ecr
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

  def initialize(out_dir, @file, @class, @author, @year)
    super out_dir
  end
end
```

#### Here we go!

```crystal
CrystalInitTemplate.new("/path/to/output", "teeplate", "Teeplate", "mosop", 2016).render
```

#### Output structure

* spec/
  * .gitignore
  * spec_helper.cr
  * teeplate_spec.cr
* src/
  * teeplate/
    * version.cr
  * teeplate.cr
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

```crystal
class Template < Teeplate::FileTree
  directory "/path/to/template"

  @face : String

  def initialize(out_dir, @face)
    super out_dir
  end
end

Template.new("/path/to/output", ":)").render
Template.new("/path/to/output", ":(").render(force: true) # files to be overwritten
Template.new("/path/to/output", ":P").render # nothing happens
```

### Interactive (WIP)

## Wish List

* Confirmation (Overwrite, Abort, Ignore...)

## Release Notes

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
