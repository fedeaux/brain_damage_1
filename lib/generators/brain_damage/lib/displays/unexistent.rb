require 'erb'
require_relative 'base'

module BrainDamage
  module Displays
    class Unexistent < Base
      def html(args = {})
        false
      end
    end
  end
end
