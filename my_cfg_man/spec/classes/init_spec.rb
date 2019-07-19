require 'spec_helper'
describe 'my_cfg_man' do
  context 'with default values for all parameters' do
    it { should contain_class('my_cfg_man') }
  end
end
