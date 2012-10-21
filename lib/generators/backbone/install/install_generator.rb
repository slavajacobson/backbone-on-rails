require 'generators/backbone/helpers'
require 'rails'

module Backbone
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Backbone::Generators::Helpers

      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a Backbone.js skeleton directory structure and manifest"

      class_option :javascript, type: :boolean, aliases: "-j", default: false,
                    desc: "Generate JavaScript"

      class_option :manifest, type: :string, aliases: "-m", default: "application.js",
                    desc: "Javascript manifest file to modify (or create)"

      def create_dir_layout
        empty_directory "#{javascript_path}/models"
        empty_directory "#{javascript_path}/collections"
        empty_directory "#{javascript_path}/routers"
        empty_directory "#{javascript_path}/views"
        empty_directory "#{asset_path}/templates"
      end

      def create_app_file
        js = options.javascript
        ext = js ? ".js" : ".js.coffee"
        template "app#{ext}", "#{javascript_path}/#{app_filename}#{ext}"
      end

      def inject_backbone
        manifest = "#{javascript_path}/#{options.manifest}"
        custom_manifest = options.manifest != 'application.js'
        libs = %w(underscore backbone)
        paths = %w(../templates ./models ./collections ./views ./routers)
        sentinel =  /\/\/=\s+require_tree\s+\.[^\/\w]*/

        in_root do
          create_file(manifest) unless File.exists?(manifest)
          out = []
          out << libs.map{ |lib| "//= require #{lib}" }
          out << "//= require #{app_filename}"
          out << paths.map{ |path| "//= require_tree #{path}" }
          out = out.join("\n") + "\n"
          if custom_manifest
            append_file(manifest, out)
          else
            inject_into_file(manifest, out, before: sentinel)
          end
        end
      end

    end
  end
end
