# my_module/lib/puppet/provider/glance_api_config/ini_setting.rb
require 'puppet/provider/pt_utils'

Puppet::Type.type(:ini_settings_encrypt).provide(
    :ini_setting,
    # set ini_setting as the parent provider
    :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
  ) do
    # super()
  end
  