require 'spec_helper'

describe 'Gemfile DSL compatibility' do
  it 'supports all Bundler DSL in Gemfile' do
    build_gem 'bacon', '1.0.0'
    build_gem 'bread', '1.0.0'
    build_gem 'miso_soup', '1.0.0'
    build_gem 'rice', '1.0.0'
    build_git_gem 'egg', '1.0.0'

    build_gemfile <<-Gemfile
      source "https://rubygems.org"
      ruby RUBY_VERSION

      git "../gems/egg" do
        gem "egg"
      end

      group :breakfast do
        gem "bacon"
      end

      gem 'appraisal', path: #{PROJECT_ROOT.inspect}
    Gemfile

    build_appraisal_file <<-Appraisals
      appraise "japanese" do
        gem "rice"
        gem "miso_soup"
      end

      appraise "english" do
        gem "bread"
      end
    Appraisals

    run 'bundle install --local --binstubs'
    run 'appraisal generate'

    expect(content_of 'gemfiles/japanese.gemfile').to include <<-Gemfile.strip_heredoc
      source "https://rubygems.org"

      ruby "#{RUBY_VERSION}"

      git "../gems/egg" do
        gem "egg"
      end

      gem "appraisal", :path=>#{PROJECT_ROOT.inspect}
      gem "rice"
      gem "miso_soup"

      group :breakfast do
        gem "bacon"
      end
    Gemfile

    expect(content_of 'gemfiles/english.gemfile').to include <<-Gemfile.strip_heredoc
      source "https://rubygems.org"

      ruby "#{RUBY_VERSION}"

      git "../gems/egg" do
        gem "egg"
      end

      gem "appraisal", :path=>#{PROJECT_ROOT.inspect}
      gem "bread"

      group :breakfast do
        gem "bacon"
      end
    Gemfile
  end

  def build_git_gem(gem_name, version)
    build_gem gem_name, version

    Dir.chdir "tmp/gems/#{gem_name}" do
      `git init .`
      `git config user.email "appraisal@thoughtbot.com"`
      `git config user.name "Appraisal"`
      `git add .`
      `git commit -a -m "initial commit"`
    end
  end
end