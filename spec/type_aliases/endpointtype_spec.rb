require 'spec_helper'

describe 'Openstack_extras::EndpointType' do
  describe 'valid types' do
    context 'with valid types' do
      [
        'public',
        'internal',
        'admin',
        'publicURL',
        'internalURL',
        'adminURL',
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
        false,
        '',
        'unknown',
        ['public'],
        {'public' => 'public'},
        '<SERVICE DEFAULT>',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
