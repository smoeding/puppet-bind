# frozen_string_literal: true

require 'spec_helper'

describe 'bind::gencfg' do
  context 'with config => String' do
    let(:config) do
      { 'foo' => 'bar' }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo bar;\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo bar;\n")
    }
  end

  context 'with config => Numeric' do
    let(:config) do
      { 'foo' => 42 }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo 42;\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo 42;\n")
    }
  end

  context 'with config => Boolean (true)' do
    let(:config) do
      { 'foo' => true }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo yes;\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo yes;\n")
    }
  end

  context 'with config => Boolean (false)' do
    let(:config) do
      { 'foo' => false }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo no;\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo no;\n")
    }
  end

  context 'with config => Array 0 elements' do
    let(:config) do
      { 'foo' => [] }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo { };\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo { };\n")
    }
  end

  context 'with config => Array 1 element' do
    let(:config) do
      { 'foo' => ['item1'] }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo { item1; };\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo { item1; };\n")
    }
  end

  context 'with config => Array 2 elements' do
    let(:config) do
      { 'foo' => %w[item1 item2] }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo {\n  item1;\n  item2;\n};\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo {\n    item1;\n    item2;\n  };\n")
    }
  end

  context 'with config => Hash' do
    let(:config) do
      { 'foo' => { 'foo' => 'bar' } }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo {\n  foo bar;\n};\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo {\n    foo bar;\n  };\n")
    }
  end

  context 'with config => multiple values' do
    let(:config) do
      { 'foo' => 'bar', 'foobar' => 'quux' }
    end

    it {
      is_expected.to run.with_params(config)
                        .and_return("foo    bar;\nfoobar quux;\n")
      is_expected.to run.with_params(config, 2)
                        .and_return("  foo    bar;\n  foobar quux;\n")
    }
  end
end
