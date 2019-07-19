require 'spec_helper'
describe 'my_utils' do
  context 'with default values for all parameters' do
    it { should contain_class('my_utils') }
  end
end
