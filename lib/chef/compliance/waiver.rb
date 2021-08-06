#
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "yaml"

class Chef
  module Compliance
    class Waiver
      # @return [Boolean] if the waiver has been enabled
      attr_accessor :enabled

      # @return [String] The name of the cookbook that the waiver is in
      attr_accessor :cookbook_name

      # @return [String] The full path on the host to the waiver yml file
      attr_accessor :path

      # @return [String] the pathname in the cookbook
      attr_accessor :pathname

      # Event dispatcher for this run.
      #
      # @return [Chef::EventDispatch::Dispatcher]
      #
      attr_accessor :events

      def initialize(events, data, path, cookbook_name)
        @events = events
        @data = data
        @cookbook_name = cookbook_name
        @path = path
        @pathname = File.basename(path, File.extname(path))
        disable!
      end

      # @return [Boolean] if the waiver has been enabled
      #
      def enabled?
        !!@enabled
      end

      # Set the waiver to being enabled
      #
      def enable!
        events.compliance_waiver_enabled(cookbook_name, pathname, path)
        @enabled = true
      end

      # Set the waiver as being disabled
      #
      def disable!
        @enabled = false
      end

      # Render the waiver in a way that it can be consumed by inspec
      #
      def for_inspec
        path
      end

      HIDDEN_IVARS = [ :@events ].freeze

      # Omit the event object from error output
      #
      def inspect
        ivar_string = (instance_variables.map(&:to_sym) - HIDDEN_IVARS).map do |ivar|
          "#{ivar}=#{instance_variable_get(ivar).inspect}"
        end.join(", ")
        "#<#{self.class}:#{object_id} #{ivar_string}>"
      end

      # Helper to construct a waiver object from a hash.  Since the path and
      # cookbook_name are required this is probably not externally useful.
      #
      def self.from_hash(events, hash, path, cookbook_name)
        new(events, hash, path, cookbook_name)
      end

      # Helper to construct a waiver object from a yaml string.  Since the path
      # and cookbook_name are required this is probably not externally useful.
      #
      def self.from_yaml(events, string, path, cookbook_name)
        from_hash(events, YAML.load(string), path, cookbook_name)
      end

      # @param filename [String] full path to the yml file in the cookbook
      # @param cookbook_name [String] cookbook that the waiver is in
      #
      def self.from_file(events, filename, cookbook_name)
        from_yaml(events, IO.read(filename), filename, cookbook_name)
      end
    end
  end
end
