require 'rails/generators/resource_helpers'
require 'rails/generators/rails/model/model_generator'
require 'active_support/core_ext/object/blank'

require_relative '../lib/resource'

module BrainDamage
  class ResourceGenerator < Rails::Generators::ModelGenerator
    include Rails::Generators::ModelHelpers
    include Rails::Generators::ResourceHelpers
    source_root File.expand_path('../templates', __FILE__)

    class_option :description, desc: "The .rb file with description for this scaffold"

    BRAIN_DAMAGE_MODEL_HOOK_TEXT_START = "\n  # BD: Code automatically generated by BrainDamage."
    BRAIN_DAMAGE_MODEL_HOOK_TEXT_END = "\n  # BD: Outside these two comments is safe to edit."

    hook_for :resource_route, required: true, in: :rails

    def self.start(args, config)
      resource = get_resource_description args
      args = resource.as_cmd_parameters
      puts args
      super
    end

    def find_brain_damage_description
    end

    def create_controller_files
      template "controller.rb", File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
    end

    def copy_view_files
      available_views.each do |view|
        filename = "#{view}.html.haml"
        template "views/#{filename}", File.join("app/views", controller_file_path, filename)
      end
    end

    def add_code_to_model
      @model_file_full_path = "app/models/#{name.downcase}.rb"

      return unless File.exists? @model_file_full_path

      inject_into_file @model_file_full_path, after: /class .+/ do
        BRAIN_DAMAGE_MODEL_HOOK_TEXT_START + BRAIN_DAMAGE_MODEL_HOOK_TEXT_END
      end
    end

    protected

    def self.get_resource_description(args)
      file = get_description_file_from_args(args)

      BrainDamage::Resource.new file
    end

    def self.get_description_file_from_args(args)
      description = args.select{ |arg|
        arg.starts_with? '--description'
      }.first

      return nil unless description

      description_file = description.split('=').last.strip.gsub('.rb', '')+'.rb'
      File.open Rails.root+'description/'+description_file
    end

    def available_views
      %w(index show _form _fields _single_page_manager _table.item _table.header _table.form _table.item.form)
    end

    def handler
      :haml
    end
  end
end
