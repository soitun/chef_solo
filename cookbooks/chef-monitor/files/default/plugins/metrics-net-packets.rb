#!/usr/bin/env ruby
#
# Linux network interface packet metrics
# ====
#
# Simple plugin that fetchs packet metrics from all interfaces
# on the box.
#
# Use with graphite and the `nonNegativeDerivative()` function
# to construct 'packets-per-second' graphs for your hosts.
#
# Loopback iface (`lo`) is ignored.
#
# Compat
# ------
#
# This plugin uses the `/sys/class/net/<iface>/statistics/{rx,tx}_packets`
# files to fetch stats. On older linux boxes without /sys, this same
# info can be fetched from /proc/net/dev but additional parsing
# will be required.
#
# Example:
# --------
#
# $ ./metrics-packets.rb --scheme servers.web01
#   servers.web01.eth0.tx_packets 982965    1351112745
#   servers.web01.eth0.rx_packets 1180186   1351112745
#   servers.web01.eth1.tx_packets 273936669 1351112745
#   servers.web01.eth1.rx_packets 563787422 1351112745
#
# Copyright 2012 Joe Miller <https://github.com/joemiller>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'socket'


class LinuxPacketMetrics < Sensu::Plugin::Metric::CLI::Graphite

  option :scheme,
    :description => "Metric naming scheme, text to prepend to metric",
    :short => "-s SCHEME",
    :long => "--scheme SCHEME",
    :default => "#{Socket.gethostname}.net"

  def run
    timestamp = Time.now.to_i

    Dir.glob('/sys/class/net/*').each do |iface_path|
      iface = File.basename(iface_path)
      next if iface == 'lo'

      tx_pkts = File.open(iface_path + '/statistics/tx_packets').read.strip
      rx_pkts = File.open(iface_path + '/statistics/rx_packets').read.strip
      output "#{config[:scheme]}.#{iface}.tx_packets", tx_pkts, timestamp
      output "#{config[:scheme]}.#{iface}.rx_packets", rx_pkts, timestamp
    end
    ok
  end

end
