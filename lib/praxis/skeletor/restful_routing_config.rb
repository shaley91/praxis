module Praxis
  module Skeletor
    class RestfulRoutingConfig

      attr_reader :name, :resource_definition, :routes

      def initialize(name, resource_definition, &block)
        @name = name
        @resource_definition = resource_definition
        @routes = []

        @version_prefix = ""
        @path_prefix = ""
        if resource_definition.version_options
          version_using = Array(resource_definition.version_options[:using])
          if version_using.include?(:path)
            @version_prefix = "#{Praxis::Request::path_version_prefix}#{resource_definition.version}"
          end
        end
        @default_path_prefix = "/" + resource_definition.name.split("::").last.underscore

        if resource_definition.routing_config
          resource_definition.routing_config.collect { |routing_config| instance_eval(&routing_config) }.join
        end

        instance_eval(&block)
      end

      def prefix(prefix=nil)
        @path_prefix += prefix if prefix
        if !@path_prefix.empty?
          @version_prefix + @path_prefix
        else
          @version_prefix + @default_path_prefix
        end
      end

      def options(path, opts={}) add_route 'OPTIONS', path, opts end
      def get(path, opts={})     add_route 'GET',     path, opts end
      def head(path, opts={})    add_route 'HEAD',    path, opts end
      def post(path, opts={})    add_route 'POST',    path, opts end
      def put(path, opts={})     add_route 'PUT',     path, opts end
      def delete(path, opts={})  add_route 'DELETE',  path, opts end
      def trace(path, opts={})   add_route 'TRACE',   path, opts end
      def connect(path, opts={}) add_route 'CONNECT', path, opts end
      def patch(path, opts={})   add_route 'PATCH',   path, opts end

      def add_route(verb, path, options={})
        path = Mustermann.new(prefix + path)

        @routes << Route.new(verb, path, resource_definition.version, **options)
      end

    end

  end
end
