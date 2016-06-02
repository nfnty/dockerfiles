''' Network '''

import itertools
import functools

import networkx


__all__ = ['DiGraph']


class DiGraph(networkx.DiGraph):
    ''' Network with generic methods '''
    def __init__(self):
        super(DiGraph, self).__init__()
        self.failed = set()

    def predecessors_all(self, source):
        ''' Predecessors of source '''
        predecessors = set()
        predecessors_new = set(self.predecessors(source))
        while predecessors_new:
            predecessors |= predecessors_new
            nodes = predecessors_new.copy()
            predecessors_new.clear()
            for node in nodes:
                predecessors_new |= set(self.predecessors(node))
        return predecessors

    def successors_all(self, source):
        ''' Successors of source '''
        return set(itertools.chain.from_iterable(networkx.dfs_successors(self, source).values()))

    def remove_nodes_from_except(self, nodes, successors=True, predecessors=True):
        ''' Remove network nodes from self except '''
        if successors and predecessors:
            self.remove_nodes_from(self.node.keys() - nodes)
        elif successors:
            self.remove_nodes_from(
                self.node.keys() -
                (nodes | functools.reduce(
                    lambda s0, s1: s0 | s1,
                    (self.predecessors_all(node) for node in nodes)
                ))
            )
        elif predecessors:
            self.remove_nodes_from(
                self.node.keys() -
                (nodes | functools.reduce(
                    lambda s0, s1: s0 | s1,
                    (self.successors_all(node) for node in nodes)
                ))
            )
        else:
            self.remove_nodes_from(
                self.node.keys() -
                (nodes | functools.reduce(
                    lambda s0, s1: s0 | s1,
                    (self.predecessors_all(node) | self.successors_all(node) for node in nodes)
                ))
            )

    def connected(self, node):
        ''' Connected components '''
        return networkx.node_connected_component(self.to_undirected(), node)
