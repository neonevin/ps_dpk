require 'digest/md5'
require 'puppet/parameter/boolean'
require 'puppet/provider/pt_utils'

Puppet::Type.newtype(:ini_settings_encrypt) do
  desc 'ini_settings_encrypt is used to manage a single setting in an INI file. This can encrypt the values'
  ensurable do
    desc 'Ensurable method handles modeling creation. It creates an ensure property'
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
    def insync?(current)
    #   if @resource[:refreshonly]
    #     true
    #   else
        current == should
    #   end
    end
    defaultto :present
  end

  def munge_boolean_md5(value)
    case value
    when true, :true, 'true', :yes, 'yes'
      :true
    when false, :false, 'false', :no, 'no'
      :false
    when :md5, 'md5'
      :md5
    else
      raise(_('expected a boolean value or :md5'))
    end
  end
  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:section) do
    desc 'The name of the section in the ini file in which the setting should be defined.'
    defaultto('')
  end

  newparam(:setting) do
    desc 'The name of the setting to be defined.'
    munge do |value|
      if value =~ %r{(^\s|\s$)}
        Puppet.warn('Settings should not have spaces in the value, we are going to strip the whitespace')
      end
      value.strip
    end
  end

  # newparam(:force_new_section_creation, boolean: true, parent: Puppet::Parameter::Boolean) do
  #   desc 'Create setting only if the section exists'
  #   defaultto(true)
  # end

  newparam(:path) do
    desc 'The ini file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise(Puppet::Error, _("File paths must be fully qualified, not '%{value}'") % { value: value })
      end
    end
  end

  newparam(:show_diff) do
    desc 'Whether to display differences when the setting changes.'

    defaultto :true

    newvalues(:true, :md5, :false)

    munge do |value|
      @resource.munge_boolean_md5(value)
    end
  end

  newparam(:key_val_separator) do
    desc 'The separator string to use between each setting name and value.'
    defaultto(' = ')
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'

    munge do |value|
      if ([true, false].include? value) || value.is_a?(Numeric)
        value.to_s
      else
        # value.strip.to_s
        get_encrypted_value (value.strip.to_s)
      end
    end

    def should_to_s(newvalue)
      if @resource[:show_diff] == :true && Puppet[:show_diff]
        newvalue
      elsif @resource[:show_diff] == :md5 && Puppet[:show_diff]
        '{md5}' + Digest::MD5.hexdigest(newvalue.to_s)
      else
        '[redacted sensitive information]'
      end
    end

    def is_to_s(value) # rubocop:disable Style/PredicateName : Changing breaks the code (./.bundle/gems/gems/puppet-5.3.3-universal-darwin/lib/puppet/parameter.rb:525:in `to_s')
      should_to_s(value)
    end

    def insync?(current)
    #   if @resource[:refreshonly]
    #     true
    #   else
        # current == should
        current == should
        Puppet.debug("should #{should}")
    #   end
    end
    def get_encrypted_value (command)
        begin
            # if Facter.value(:osfamily) == 'windows'
            #     return command
            # else
                enc_value = execute_command(command)
                if enc_value.include? "<password>" # when password is not provided
                    return ''
                end
            # end
        rescue Puppet::ExecutionFailure => e
                raise Puppet::Error, "Unable to encrypt password: #{e.message}"
        end
        Puppet.debug("enc_value #{enc_value}")
      return enc_value
      end        

  end

#   def refresh
#     if self[:ensure] == :absent && self[:refreshonly]
#       return provider.destroy
#     end
#     # update the value in the provider, which will save the value to the ini file
#     provider.value = self[:value] if self[:refreshonly]
#   end

  autorequire(:file) do
    Pathname.new(self[:path]).parent.to_s
  end
end
