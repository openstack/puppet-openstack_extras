require 'spec_helper'

describe 'Openstack_extras::ApiVersion' do
  describe 'valid types' do
    context 'with valid types' do
      [
        1,
        2,
        1.0,
        2.1,
        '1',
        '2',
        '1.0',
        '2.1',
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        nil,
        0,
        -1,
        0.9,
        -0.1,
        false,
        '',
        '-1',
        '-1.0',
        '0.9',
        '1.1.2',
        '1.1a',
        '<SERVICE DEFAULT>',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
