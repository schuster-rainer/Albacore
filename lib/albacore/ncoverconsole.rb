require 'albacore/support/albacore_helper'

class NCoverConsole
  extend AttrMethods
  include RunCommand
  include YAMLConfig
  
  attr_accessor :testrunner, :working_directory
  attr_array :cover_assemblies, :ignore_assemblies, :coverage
  attr_hash :output
  
  def initialize
    @register_dll = true
    @output = {}
    @cover_assemblies = []
    @ignore_assemblies = []
    @coverage = []
    super()
  end
  
  def working_directory=(working_dir)
    @working_directory = "//working-directory " + working_dir
  end
  
  def no_registration
    @register_dll = false
  end
  
  def run
    return unless check_for_testrunner
    
    command_parameters = []
    command_parameters << "//reg" if @register_dll
    command_parameters << build_output_options(@output) unless @output.nil?
    command_parameters << @working_directory unless @working_directory.nil?
    command_parameters << build_assembly_list("assemblies", @cover_assemblies) unless @cover_assemblies.empty?
    command_parameters << build_assembly_list("exclude-assemblies", @ignore_assemblies) unless @ignore_assemblies.empty?
    command_parameters << build_coverage_list(@coverage) unless @coverage.empty?
    command_parameters << @testrunner.get_command_line
    
    result = run_command "NCover.Console", command_parameters.join(" ")
    
    failure_msg = 'Code Coverage Analysis Failed. See Build Log For Detail.'
    fail_with_message failure_msg if !result
  end
  
  def check_for_testrunner
    return true if (!@testrunner.nil?)
    msg = 'testrunner cannot be nil.'
    @logger.info msg
    fail
    return false
  end
  
  def build_output_options(output)
    options = []
    output.each do |key, value|
      options << "//#{key} #{value}"
    end
    options.join(" ")
  end
  
  def build_assembly_list(param_name, list)
    assembly_list = list.map{|asm| "\"#{asm}\""}.join(';')
    "//#{param_name} #{assembly_list}"
  end
  
  def build_coverage_list(coverage)
    "//coverage-type \"#{coverage.join(', ')}\""
  end
end
