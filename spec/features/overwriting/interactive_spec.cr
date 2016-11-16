require "../../spec_helper"
require "stdio"

module TeeplateOverwritingInteractiveFeature
  extend HaveFiles::Spec::Dsl

  PROMPT = "overwrite(o)/keep(k)/diff(d)/overwrite all(a)/keep all(n) ? "

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/interactive/template"

    @face : String

    def initialize(@face)
    end
  end

  it name do
    HaveFiles.tmpdir do |debug|
      HaveFiles.tmpdir do |tmp|
        test_path = "#{tmp}/test"
        stdin = STDIN
        Template.new(":)").render(tmp)
        Stdio.capture do |io|
          fork do
            prompt = ""
            loop do
              if ch = io.out!.read_char
                prompt += ch
                break if prompt.ends_with?(Teeplate::FileTree::PROMPT)
              else
                sleep 0.1
              end
            end
            io.in.puts "o"
          end
          Template.new(":(").render(tmp, interactive: true)
        end
        File.read(test_path).should eq ":(\n"
        Stdio.capture do |io|
          fork do
            prompt = ""
            loop do
              if ch = io.out!.read_char
                prompt += ch
                break if prompt.ends_with?(Teeplate::FileTree::PROMPT)
              else
                sleep 0.1
              end
            end
            io.in.puts "k"
          end
          Template.new(":P").render(tmp, interactive: true)
        end
        File.read(test_path).should eq ":(\n"
      end
    end
  end
end
