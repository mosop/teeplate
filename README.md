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
template = CrystalInitTemplate.new("teeplate", "Teeplate", "mosop", 2016)
template.render "/path/to/output"
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
Template.new(":(").render("/path/to/output", force: true) # files may be overwritten
Template.new(":P").render("/path/to/output") # nothing happens
```

### Interactive

If the `:interactive` option is true, Teeplate prompts us to select whether to overwrite an existing file.

```
shard.yml already exists...
overwrite(o)/keep(k)/diff(d)/overwrite all(a)/keep all(n) ?
```

## Listing Rendered Files

You can print a list of rendered files. To enable it, set true to the `:list` option and call #render.

```crystal
template = BrandNewCrystalInitTemplate.new("teeplate", "Teeplate", "mosop", 2017)
template.render "/path/to/overwrite", list: true
```

Output example:

```
modified  .gitignore
identical .travis.yml
new       Dockerfile
skipped   LICENSE
skipped   README.md
skipped   shard.yml
modified  spec/spec_helper.cr
skipped   spec/teeplate_spec.cr
skipped   src/teeplate/version.cr
skipped   src/teeplate.cr
```

You can colorize the output by the `:color` option.

```crystal
template.render "/path/to/overwrite", list: true, color: true
```

## Want-to-do

* Merge on overwriting

## Release Notes

* v0.3.0
  * Quit on overwriting
  * Rendering with append mode (see [the issue](https://github.com/mosop/teeplate/issues/2))
  * Teeplate::FileTree#render prints a list of rendered files with the :list option.
* v0.2.0
  * (Breaking Change) FileTree#initialize does not receive an output directory. Instead, FileTree#render does.
  * Diff on overwriting confirmation
  * Overwrite All / Keep All on overwriting confirmation
* v0.1.3
  * :interactive option to select whether to overwrite existing files
* v0.1.2
  * :force option to overwrite output files if they exist
