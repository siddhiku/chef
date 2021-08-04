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

require_relative "waiver"

class Chef
  module Compliance
    class WaiverCollection < Array

      # Add a waiver to the waiver collection.  The cookbook_name needs to be determined by the
      # caller and is used in the `include_waiver` API to match on.  The path should be the complete
      # path on the host of the yml file, including the filename.
      #
      # @param cookbook_name [String]
      # @param path [String]
      #
      def from_file(cookbook, filename)
        self << Waiver.from_file(cookbook, filename)
      end

      # @return [Array<Waiver>] inspec waivers which are enabled in a form suitable to pass to inspec
      #
      def for_inspec
        select(&:enabled?).each_with_object([]) { |waiver, arry| arry << waiver.for_inspec }
      end

      # DSL method to enable waiver files.  This matches on the name of the profile being wavied, it
      # does not match on the filename of the waiver file.
      #
      # @example Specific waiver file in a cookbook
      #
      # include_waiver "acme_cookbook::ssh-001"
      #
      # @example Every waiver file in a cookbook
      #
      # include_waiver "acme_cookbook"
      #
      # @example Matching waivers by regexp in a cookbook
      #
      # include_waiver "acme_cookbook::ssh.*"
      #
      # @example Matching waivers by regexp in any cookbook in the cookbook collection
      #
      # include_waiver ".*::ssh.*"
      #
      def include_waiver(arg)
        (cookbook_name, waiver_name) = arg.split("::")
        waivers = nil

        if waiver_name.nil?
          waivers = select { |waiver| /^#{cookbook_name}$/.match?(waiver.cookbook_name) }
          if waivers.empty?
            raise "No inspec waivers found in cookbooks matching #{cookbook_name}"
          end
        else
          waivers = select { |waiver| /^#{cookbook_name}$/.match?(waiver.cookbook_name) && /^#{waiver_name}$/.match?(waiver.name) }
          if waivers.empty?
            raise "No inspec waivers matching #{waiver_name} found in cookbooks matching #{cookbook_name}"
          end
        end

        waivers.each(&:enable!)
      end
    end
  end
end
