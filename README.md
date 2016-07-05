# Teeplate

A Crystal library for generating files from templates.

[![Build Status](https://travis-ci.org/mosop/teeplate.svg?branch=master)](https://travis-ci.org/mosop/teeplate)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  teeplate:
    github: mosop/teeplate
```

## Features

<a name="features"></a>

### File Tree Template

#### Template directory structure

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

#### Output directory structure

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

#### Output file example

```yaml
# shard.yml
name: teeplate
version: 0.1.0

authors:
  - mosop

license: MIT
```

## Usage

```crystal
require "teeplate"
```

and see [Features](#features)

# Wish List

* Confirmation (Overwrite, Abort, Ignore...)

## Contributing

1. Fork it ( https://github.com/mosop/teeplate/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mosop](https://github.com/mosop) - creator, maintainer
