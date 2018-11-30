require 'spec_helper'

describe 'validate_yum_hash' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'throws error with more than one argument' do
    is_expected.to run.with_params({'title' => {'key1' => 'value1'}, 'title2' => {'key2' => 'value2'}}).and_raise_error(Puppet::Error)
  end

  it 'fails with no arguments' do
    is_expected.to run.with_params.and_raise_error(Puppet::Error)
  end

  it 'fails with invalid hash' do
    is_expected.to run.with_params({'title' => {'invalid' => 'val'}}).and_raise_error(Puppet::Error)
  end

  it 'fails with invalid hash with multiple entries' do
    is_expected.to run.with_params({'title' => {'baseurl' => 'placeholder', 'invalid' => 'val'}}).and_raise_error(Puppet::Error)
  end

  it 'works with valid entry' do
    is_expected.to run.with_params({'title' => {'baseurl' => 'placeholder'}})
  end

  it 'works with multiple valid entries' do
    is_expected.to run.with_params({'title' => {'baseurl' => 'placeholder', 'timeout' => 30}})
  end
end
