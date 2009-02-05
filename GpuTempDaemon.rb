#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

require 'GpuTempSetter'

#TODO: accept runtime options, to toggle info printing for example

Daemons.run_proc("GpuTempSetter") do
  gpuTempSetter = GpuTempSetter.new()
  loop do
    gpuTempSetter.autoTemp()
#    gpuTempSetter.printInfo()
#    puts "---"
    sleep(5)
  end
end
