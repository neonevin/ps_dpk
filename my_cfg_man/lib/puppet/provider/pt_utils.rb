# ***************************************************************
#  This software and related documentation are provided under a
#  license agreement containing restrictions on use and
#  disclosure and are protected by intellectual property
#  laws. Except as expressly permitted in your license agreement
#  or allowed by law, you may not use, copy, reproduce,
#  translate, broadcast, modify, license, transmit, distribute,
#  exhibit, perform, publish or display any part, in any form or
#  by any means. Reverse engineering, disassembly, or
#  decompilation of this software, unless required by law for
#  interoperability, is prohibited.
#  The information contained herein is subject to change without
#  notice and is not warranted to be error-free. If you find any
#  errors, please report them to us in writing.
#
#  Copyright (C) 1988, 2017, Oracle and/or its affiliates.
#  All Rights Reserved.
# ***************************************************************

require 'open3'

def strip_keyval_array(input_array)

  result = []
  # strip whitespace
  input_array.each do |element|
    key = element.split('=')[0].strip

    if element.split('=')[1].nil? == false
      val = element.split('=', 2)[1].strip
    else
      val = ''
    end

    item = key + '=' + val
    result.push(item)
  end
  return result
end

def regsubst_array(input_array, regexp, replacement)
  begin
    re = Regexp.compile(regexp)

  rescue RegexpError, TypeError
    raise(Puppet::ParseError, "Bad regular expression `#{regexp}'")
  end
  result = input_array.collect { |e|
    e.send(:sub, re, replacement)
  }
  return result
end

def execute_command(command, env={}, mask_pwd = false)
  Puppet.debug("Executing command: #{command}")
  out_str = ''
  if Facter.value(:osfamily) == 'windows'
    Open3.popen2e(env, command) do |stdin, stdout_err, wait_thr|
      pid = wait_thr.pid # pid of the started process
      Puppet.debug("Started thread PID: #{pid}")

      Thread.new do
        stdout_err.each do |line|
          out_str += line

          line.delete!("\n")
          unless mask_pwd
            Puppet.debug(line)
          end
        end
      end
      stdin.close
      Puppet.debug("Waiting for the thread PID: #{pid} to finish")
      exit_status = wait_thr.value

      Puppet.debug("Command status: #{exit_status}")
      unless exit_status.success?
        if out_str.include?('TMADMIN_CAT:111:') == false && out_str.include?('') == false
          raise Puppet::ExecutionFailure, "Command execution failed, error: [#{out_str}]"
        end
      end
      out_str.delete!("\n")
      if mask_pwd
        Puppet.debug('Command executed successfully')
      else
        Puppet.debug("Command executed successfully, output: [#{out_str}]")
      end
    end
  else
      error_str = ''
    begin
      Open3.popen3(command) do |stdin, out, err|
        stdin.close
        error_str = err.read
        out_str = out.read

        out_str = out_str + '' + error_str
        if mask_pwd
          Puppet.debug('Command executed successfully')
        else
          Puppet.debug("Command executed successfully, Output: #{out_str}, Error: #{error_str}")
        end

      end
    rescue Exception => e
      raise Puppet::ExecutionFailure, "Command execution failed, error: #{e.message} "
    end
  end
  return out_str
end


# def get_encrypted_value (password, command)
#   begin
#       Puppet.debug("encrypt #{password}")
#       # if resource[:encrypt] == true
#           enc_value = execute_command(command)

#       # else
#           # enc_value =  resource[:value]
#       # end
#   rescue Puppet::ExecutionFailure => e
#       # if e.message.include?('returned 40')
#           raise Puppet::Error, "Unable to encrypt password: #{e.message}"
#       # end
#   end
#   Puppet.debug("enc_value #{enc_value}")
# return enc_value
# end