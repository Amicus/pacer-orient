require 'yaml'

module Pacer
  OrientGraph = com.tinkerpop.blueprints.pgm.impls.orientdb.OrientGraph
  OrientElement = com.tinkerpop.blueprints.pgm.impls.orientdb.OrientElement

  # Add 'static methods' to the Pacer namespace.
  class << self
    # Return a graph for the given path. Will create a graph if none exists at
    # that location. (The graph is only created if data is actually added to it).
    def orient(url, username = nil, password = nil)
      Pacer.starting_graph(self, url) do
        if username
          OrientGraph.new(url, username, password)
        else
          OrientGraph.new(url)
        end
      end
    end
  end


  # Extend the java class imported from blueprints.
  class OrientGraph
    include GraphMixin
    include GraphIndicesMixin
    include GraphTransactionsMixin
    include ManagedTransactionsMixin
    include Pacer::Core::Route
    include Pacer::Core::Graph::GraphRoute
    include Pacer::Core::Graph::GraphIndexRoute

    # Override to return an enumeration-friendly array of vertices.
    def get_vertices
      getVertices.to_route(:graph => self, :element_type => :vertex)
    end

    # Override to return an enumeration-friendly array of edges.
    def get_edges
      getEdges.to_route(:graph => self, :element_type => :edge)
    end

    def element_class
      OrientElement
    end

    def vertex_class
      OrientVertex
    end

    def edge_class
      OrientEdge
    end

    def sanitize_properties(props)
      pairs = props.map do |name, value|
        [name, encode_property(value)]
      end
      Hash[pairs]
    end

    def encode_property(value)
      case value
      when nil
        nil
      when String
        value = value.strip
        value = nil if value == ''
        value
      when Numeric
        if value.is_a? Bignum
          value.to_yaml
        else
          value
        end
      else
        value.to_yaml
      end
    end

    if 'x'.to_yaml[0, 5] == '%YAML'
      def decode_property(value)
        if value.is_a? String and value[0, 5] == '%YAML'
          YAML.load(value)
        else
          value
        end
      end
    else
      def decode_property(value)
        if value.is_a? String and value[0, 3] == '---'
          YAML.load(value)
        else
          value
        end
      end
    end

    def supports_circular_edges?
      false
    end

    def supports_custom_element_ids?
      false
    end
  end
end
