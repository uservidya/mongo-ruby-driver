# encoding: UTF-8

# --
# Copyright (C) 2008-2011 10gen Inc.
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
# ++
module LegacyWarning
  @@warn = 0
  def show_class_warning
    if @@warn == 0 || (@@warn % 5 == 0)
      warn "[DEPRECATED] #{self.class.name} has been replaced with #{self.class.superclass.name}."
    end
    @@warn += 1
  end
end

module Mongo
  # @deprecated Use Mongo::Client instead.
  class Connection < Client
    include LegacyWarning
    def initialize(host=nil, port=nil, opts={})
      show_class_warning
      super
    end
  end

  # @deprecated Use Mongo::ReplSetClient instead.
  class ReplSetConnection < ReplSetClient
    include LegacyWarning
    def initialize(*args)
      show_class_warning
      super
    end
  end

  # @deprecated Use Mongo::ShardedClient instead.
  class ShardedConnection < ShardedClient
    include LegacyWarning
    def initialize(*args)
      show_class_warning
      super
    end
  end
end