''' Network '''

import itertools
import functools

import networkx


__all__ = ['DiGraph']


class DiGraph(networkx.DiGraph):
    ''' Network with generic methods '''
    def __init__(self):
        super(DiGraph, self).__init__()

    def successors_all(self, source):
        ''' Successors of source '''
        return set(itertools.chain.from_iterable(networkx.dfs_successors(self, source).values()))

    def remove_nodes_from_except(self, nodes, successors):
        ''' Remove network nodes except nodes
            Prune successors if True '''
        if successors:
            self.remove_nodes_from(self.node.keys() - nodes)
        else:
            self.remove_nodes_from(self.node.keys() - (nodes | functools.reduce(
                lambda s0, s1: s0 | s1, (self.successors_all(node) for node in nodes))))

    def connected(self, node):
        ''' Connected components '''
        return networkx.node_connected_component(self.to_undirected(), node)
