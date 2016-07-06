require "../../spec_helper"
require "stdio"

module TeeplateOverwritingInteractiveFeature
  extend HaveFiles::Spec::Dsl

  PROMPT = "O(overwrite)/K(keep) ? "

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/interactive/template"

    @face : String

    def initialize(out_dir, @face)
      super out_dir
    end
  end

  it name do
    HaveFiles.tmpdir do |debug|
      HaveFiles.tmpdir do |tmp|
        test_path = "#{tmp}/test"
        stdin = STDIN
        Template.new(tmp, ":)").render
        Stdio.capture do |io|
          fork do
            prompt = ""
            loop do
              if ch = io.out?.read_char
                prompt += ch
                break if prompt.ends_with?(Teeplate::FileTree::PROMPT)
              else
                sleep 0.1
              end
            end
            io.in.puts "o"
          end
          Template.new(tmp, ":(").render(interactive: true)
        end
        File.read(test_path).should eq ":(\n"
        Stdio.capture do |io|
          fork do
            prompt = ""
            loop do
              if ch = io.out?.read_char
                prompt += ch
                break if prompt.ends_with?(Teeplate::FileTree::PROMPT)
              else
                sleep 0.1
              end
            end
            io.in.puts "k"
          end
          Template.new(tmp, ":P").render(interactive: true)
        end
        File.read(test_path).should eq ":(\n"
      end
    end
  end
end
