lib_path = File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
$:.unshift lib_path unless $:.any? { |path| path == lib_path }

require 'orientdb'
require 'pacer' unless defined? Pacer
require 'pacer-orient/version'
require 'pacer-orient/encoder'

module Pacer
  class << self
    # Return a graph for the given url. There are 3 ways to open an Orient graph:
    #
    # * memory - url is nil or "memory:a_name"
    # * local - url is a simple path
    # * remote - url is "remote:localhost/a_name"
    #
    # Orient documentation: http://code.google.com/p/orient/wiki/Main
    #
    # Local embedded graph will create a graph at specified location if one
    # doesn't exist already.
    def orient(url = nil, username = nil, password = nil)
      if url.nil?
        url = "memory:#{ next_orient_name }"
      elsif url !~ /^(local|remote|memory):/
        url = "local:#{ url }"
      end
      orient = com.tinkerpop.blueprints.impls.orient.OrientGraph
      open = proc do
        graph = Pacer.open_graphs[[url, username]]
        unless graph
          if username
            graph = orient.new(url, username, password)
          else
            graph = orient.new(url)
          end
          Pacer.open_graphs[[url, username]] = graph
        end
        graph
      end
      shutdown = proc do |g|
        g.blueprints_graph.shutdown
        Pacer.open_graphs.delete [url, username]
      end
      PacerGraph.new(Pacer::Orient::Encoder, open, shutdown)
    end

    private

    def next_orient_name
      @next_orient_name ||= "orient000"
      @next_orient_name.succ!
    end
  end
end
