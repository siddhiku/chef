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

require_relative "profile"

class Chef
  module Compliance
    class ProfileCollection < Array

      # Add a profile to the profile collection.  The cookbook_name needs to be determined by the
      # caller and is used in the `include_profile` API to match on.  The path should be the complete
      # path on the host of the inspec.yml file, including the filename.
      #
      # @param cookbook_name [String]
      # @param path [String]
      #
      def from_file(cookbook_name, path)
        self << Profile.from_file(cookbook_name, path)
      end

      # @return [Boolean] if any of the profiles are enabled
      #
      def using_profiles?
        any?(&:enabled?)
      end

      # @return [Array<Profile>] inspec profiles which are enabled in a form suitable to pass to inspec
      #
      def for_inspec
        select(&:enabled?).each_with_object([]) { |profile, arry| arry << profile.for_inspec }
      end

      # DSL method to enable profiles.  This matches on the name of the profile, it does not match on
      # the filename of the profile.
      #
      # @example Specific profile in a cookbook
      #
      # include_profile "acme_cookbook::ssh-001"
      #
      # @example Every profile in a cookbook
      #
      # include_profile "acme_cookbook"
      #
      # @example Matching profiles by regexp in a cookbook
      #
      # include_profile "acme_cookbook::ssh.*"
      #
      # @example Matching profiles by regexp in any cookbook in the cookbook collection
      #
      # include_profile ".*::ssh.*"
      #
      def include_profile(arg)
        (cookbook_name, profile_name) = arg.split("::")
        profiles = nil

        if profile_name.nil?
          profiles = select { |profile| /^#{cookbook_name}$/.match?(profile.cookbook_name) }
          if profiles.empty?
            raise "No inspec profiles found in cookbooks matching #{cookbook_name}"
          end
        else
          profiles = select { |profile| /^#{cookbook_name}$/.match?(profile.cookbook_name) && /^#{profile_name}$/.match?(profile.name) }
          if profiles.empty?
            raise "No inspec profiles matching #{profile_name} found in cookbooks matching #{cookbook_name}"
          end
        end

        profiles.each(&:enable!)
      end
    end
  end
end
