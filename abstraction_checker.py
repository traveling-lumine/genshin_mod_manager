import re
import sys
from dataclasses import dataclass, field
from typing import Dict, List, Optional


@dataclass
class Node:
    id: str
    label: str
    cd: int
    in_degree: int
    out_degree: int
    instability: float
    sloc: int


@dataclass
class Subgraph:
    id: str
    label: str
    nodes: List[str] = field(default_factory=list)
    subgraphs: List["Subgraph"] = field(default_factory=list)


@dataclass
class Edge:
    from_node: str
    to_node: str
    directive: str


@dataclass
class Metrics:
    is_acyclic: bool
    first_cycle: List[str]
    num_nodes: int
    num_edges: int
    avg_degree: float
    orphans: List[str]
    ccd: int
    acd: float
    nccd: float
    total_sloc: int
    avg_sloc: float


@dataclass
class LakosData:
    root_dir: str
    nodes: Dict[str, Node] = field(default_factory=dict)
    subgraphs: List[Subgraph] = field(default_factory=list)
    edges: List[Edge] = field(default_factory=list)
    metrics: Optional[Metrics] = None


import json


def parse_lakos_data(json_data: dict) -> LakosData:
    # Parse nodes
    nodes = {
        node_id: Node(
            id=node_id,
            label=node_data["label"],
            cd=node_data["cd"],
            in_degree=node_data["inDegree"],
            out_degree=node_data["outDegree"],
            instability=node_data["instability"],
            sloc=node_data["sloc"],
        )
        for node_id, node_data in json_data["nodes"].items()
    }

    # Parse subgraphs recursively
    def parse_subgraphs(subgraphs_data: List[dict]) -> List[Subgraph]:
        subgraphs = []
        for sg in subgraphs_data:
            subgraphs.append(
                Subgraph(
                    id=sg["id"],
                    label=sg["label"],
                    nodes=sg.get("nodes", []),
                    subgraphs=parse_subgraphs(sg.get("subgraphs", [])),
                )
            )
        return subgraphs

    subgraphs = parse_subgraphs(json_data.get("subgraphs", []))

    # Parse edges
    edges = [
        Edge(
            from_node=edge["from"],
            to_node=edge["to"],
            directive=edge["directive"],
        )
        for edge in json_data.get("edges", [])
    ]

    # Parse metrics
    metrics = (
        Metrics(
            acd=json_data["metrics"]["acd"],
            avg_degree=json_data["metrics"]["avgDegree"],
            avg_sloc=json_data["metrics"]["avgSloc"],
            ccd=json_data["metrics"]["ccd"],
            first_cycle=json_data["metrics"]["firstCycle"],
            is_acyclic=json_data["metrics"]["isAcyclic"],
            nccd=json_data["metrics"]["nccd"],
            num_edges=json_data["metrics"]["numEdges"],
            num_nodes=json_data["metrics"]["numNodes"],
            orphans=json_data["metrics"]["orphans"],
            total_sloc=json_data["metrics"]["totalSloc"],
        )
        if "metrics" in json_data
        else None
    )

    return LakosData(
        root_dir=json_data["rootDir"],
        nodes=nodes,
        subgraphs=subgraphs,
        edges=edges,
        metrics=metrics,
    )


_REGEX = re.compile(r".*/l(\d+)/.*")


def check_violations(lakos_data: LakosData):
    print("\n== Checking for violations:")

    violations = []

    module_dependencies = set()
    for edge in lakos_data.edges:
        try:
            from_index = int(_REGEX.match(edge.from_node).group(1))
        except AttributeError:
            from_index = 0
        try:
            to_index = int(_REGEX.match(edge.to_node).group(1))
        except AttributeError:
            to_index = 0

        from_module = "/".join(edge.from_node.split("/")[:3])
        to_module = "/".join(edge.to_node.split("/")[:3])

        module_dependencies.add((from_module, to_module))

        from_is_di = "/di/" in edge.from_node
        to_is_di = "/di/" in edge.to_node

        is_both_di = from_is_di and to_is_di
        is_same_module = from_module == to_module

        cur_violation = None
        if not is_same_module and to_index > 0 and not to_is_di:
            cur_violation = "Abstraction violation:"
        elif is_same_module and is_both_di and from_index > to_index:
            cur_violation = "Possible circular DI:"
        elif is_same_module and not is_both_di and from_index < to_index:
            cur_violation = "Violation:"

        if cur_violation is not None:
            violations.append(
                (cur_violation, f"    {edge.from_node}\n -> {edge.to_node}")
            )

    # detect circular module dependencies
    for from_module, to_module in module_dependencies:
        if (to_module, from_module) in module_dependencies and from_module != to_module and from_module < to_module:
            violations.append(
                ("Mutual module dependency:", f"    {from_module} <-> {to_module}")
            )

    if len(violations) == 0:
        print("No violations found.")
    else:
        sorted_ = sorted(violations)
        current = None
        for violation in sorted_:
            if violation[0] != current:
                print(violation[0])
                current = violation[0]
            print(violation[1])


def print_nodes_by_out_degree(lakos_data: LakosData, reverse=True):
    limit = 5
    print(f"\n== Top {limit} nodes by out degree:")
    sorted_nodes = sorted(
        lakos_data.nodes.values(), key=lambda node: node.out_degree, reverse=reverse
    )
    for node in sorted_nodes[:limit]:
        print(f"{node.id}: {node.out_degree}")


def print_nodes_by_in_degree(lakos_data: LakosData, reverse=True):
    limit = 5
    print(f"\n== Top {limit} nodes by in degree:")
    sorted_nodes = sorted(
        lakos_data.nodes.values(), key=lambda node: node.in_degree, reverse=reverse
    )
    for node in sorted_nodes[:limit]:
        print(f"{node.id}: {node.in_degree}")


def print_nodes_by_instability(lakos_data: LakosData):
    limit = 5
    print(f"\n== Top {limit} nodes by instability:")
    sorted_nodes = sorted(
        lakos_data.nodes.values(),
        key=lambda node: node.instability if node.instability is not None else 2,
        reverse=True,
    )
    for node in sorted_nodes[:limit]:
        print(f"{node.id}: {node.instability}")


def print_nodes_by_cd(lakos_data: LakosData):
    limit = 5
    print(f"\n== Top {limit} nodes by CD:")
    sorted_nodes = sorted(
        lakos_data.nodes.values(), key=lambda node: node.cd, reverse=True
    )
    for node in sorted_nodes[:limit]:
        print(f"{node.id}: {node.cd}")


# Example Usage
def print_lakos_metrics(lakos_data):
    print("\n== Metrics")
    print(lakos_data.metrics)


if __name__ == "__main__":
    json_data = json.load(sys.stdin)
    lakos_data = parse_lakos_data(json_data)
    check_violations(lakos_data)
    print_nodes_by_out_degree(lakos_data, False)
    print_nodes_by_out_degree(lakos_data)
    print_nodes_by_in_degree(lakos_data, False)
    print_nodes_by_in_degree(lakos_data)
    print_nodes_by_instability(lakos_data)
    print_nodes_by_cd(lakos_data)
    print_lakos_metrics(lakos_data)
