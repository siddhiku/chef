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

class Chef
  module Compliance
    class Profile

      # @return [Boolean] if the profile has been enabled
      attr_accessor :enabled

      # @return [String] The full path on the host to the profile inspec.yml
      attr_reader :path

      # @return [String] The name of the cookbook that the profile is in
      attr_reader :cookbook_name

      def initialize(data, path, cookbook_name)
        @data = data
        @path = path
        @cookbook_name = cookbook_name
        disable!
        validate!
      end

      # @return [String] name of the inspec profile from parsing the inspec.yml
      #
      def name
        @data["name"]
      end

      # Raises if the inspec profile is not valid.
      #
      def validate!
        raise "Inspec profile at #{path} has no name" unless name
      end

      # @return [Boolean] if the profile has been enabled
      #
      def enabled?
        !!@enabled
      end

      # Set the profile to being enabled
      #
      def enable!
        @enabled = true
      end

      # Set the profile as being disabled
      #
      def disable!
        @enabled = false
      end

      # Render the profile in a way that it can be consumed by inspec
      #
      def for_inspec
        { name: name, path: File.dirname(path) }
      end

      # Helper to construct a profile object from a hash.  Since the path and
      # cookbook_name are required this is probably not externally useful.
      #
      def self.from_hash(hash, path, cookbook_name)
        new(hash, path, cookbook_name)
      end

      # Helper to consruct a profile object from a yaml string.  Since the path
      # and cookbook_name are required this is probably not externally useful.
      #
      def self.from_yaml(string, path, cookbook_name)
        from_hash(YAML.load(string), path, cookbook_name)
      end

      # @param filename [String] full path to the inspec.yml file in the cookbook
      # @param cookbook_name [String] cookbook that the profile is in
      #
      def self.from_file(filename, cookbook_name)
        from_yaml(IO.read(filename), filename, cookbook_name)
      end
    end
  end
end
