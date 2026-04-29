"""
template_gnn_module.py — BMAD DL Lifecycle
(Inspired by K-Dense claude-scientific-skills/pytorch-geometric/)

PyTorch Geometric (PyG) template for Graph Neural Network tasks.
Covers GCN, GAT, GraphSAGE, and GIN architectures for:
  - Node classification  (predicting labels for each node in a graph)
  - Graph classification (predicting a label for an entire graph)

Use this for defect detection on circuit graphs, molecular property prediction,
social network analysis, or any graph-structured data.

Requires: pip install torch-geometric

Usage:
    Copy this file to src/models/your_gnn.py and:
    1. Choose an architecture (GCN / GAT / GraphSAGE / GIN)
    2. Set in_channels to your node feature dimension
    3. Set out_channels to number of classes
    4. Wrap with your LightningModule or use train/test helpers directly
"""

from __future__ import annotations

from typing import Optional

try:
    import torch
    import torch.nn as nn
    import torch.nn.functional as F
    HAS_TORCH = True
except ImportError:
    HAS_TORCH = False
    raise ImportError("Install PyTorch: pip install torch")

try:
    from torch_geometric.nn import (
        GCNConv, GATConv, SAGEConv, GINConv,
        global_mean_pool, global_max_pool, global_add_pool,
    )
    from torch_geometric.data import Data, DataLoader
    HAS_PYG = True
except ImportError:
    HAS_PYG = False
    raise ImportError(
        "Install PyTorch Geometric: pip install torch-geometric\n"
        "See: https://pytorch-geometric.readthedocs.io/en/latest/install/installation.html"
    )


# ══════════════════════════════════════════════════════════════════════════════
# Architecture 1: GCN — Graph Convolutional Network
# Best for: Homophilic graphs (connected nodes tend to share labels)
# ══════════════════════════════════════════════════════════════════════════════

class GCN(nn.Module):
    """
    Graph Convolutional Network (Kipf & Welling, 2017).

    Args:
        in_channels:   Dimension of input node features.
        hidden_channels: Hidden layer dimension.
        out_channels:  Number of output classes.
        num_layers:    Number of GCN layers (2-4 recommended).
        dropout:       Dropout rate.
        task:          'node' or 'graph' classification.
    """
    def __init__(
        self, in_channels: int, hidden_channels: int, out_channels: int,
        num_layers: int = 3, dropout: float = 0.5, task: str = "node",
    ):
        super().__init__()
        self.task = task
        self.dropout = dropout

        self.convs = nn.ModuleList()
        self.bns = nn.ModuleList()

        for i in range(num_layers):
            in_ch = in_channels if i == 0 else hidden_channels
            self.convs.append(GCNConv(in_ch, hidden_channels))
            self.bns.append(nn.BatchNorm1d(hidden_channels))

        self.classifier = nn.Linear(hidden_channels, out_channels)

    def forward(self, x: torch.Tensor, edge_index: torch.Tensor,
                batch: Optional[torch.Tensor] = None) -> torch.Tensor:
        for conv, bn in zip(self.convs[:-1], self.bns[:-1]):
            x = F.relu(bn(conv(x, edge_index)))
            x = F.dropout(x, p=self.dropout, training=self.training)

        x = self.convs[-1](x, edge_index)

        if self.task == "graph":
            x = global_mean_pool(x, batch)

        return self.classifier(x)


# ══════════════════════════════════════════════════════════════════════════════
# Architecture 2: GAT — Graph Attention Network
# Best for: Graphs where some neighbors are more important than others
# ══════════════════════════════════════════════════════════════════════════════

class GAT(nn.Module):
    """
    Graph Attention Network (Veličković et al., 2018).
    Multi-head attention assigns different importance to each neighbor.

    Args:
        in_channels:     Dimension of input node features.
        hidden_channels: Hidden layer dimension per head.
        out_channels:    Number of output classes.
        heads:           Number of attention heads (4-8 recommended).
        dropout:         Dropout rate (applied to attention weights too).
        task:            'node' or 'graph' classification.
    """
    def __init__(
        self, in_channels: int, hidden_channels: int, out_channels: int,
        heads: int = 4, dropout: float = 0.5, task: str = "node",
    ):
        super().__init__()
        self.task = task
        self.dropout = dropout

        self.conv1 = GATConv(in_channels, hidden_channels, heads=heads, dropout=dropout)
        self.conv2 = GATConv(hidden_channels * heads, out_channels, heads=1,
                             concat=False, dropout=dropout)
        self.bn1 = nn.BatchNorm1d(hidden_channels * heads)

    def forward(self, x: torch.Tensor, edge_index: torch.Tensor,
                batch: Optional[torch.Tensor] = None) -> torch.Tensor:
        x = F.dropout(x, p=self.dropout, training=self.training)
        x = F.elu(self.bn1(self.conv1(x, edge_index)))
        x = F.dropout(x, p=self.dropout, training=self.training)
        x = self.conv2(x, edge_index)

        if self.task == "graph":
            x = global_mean_pool(x, batch)

        return x  # Raw logits — apply softmax/sigmoid in loss


# ══════════════════════════════════════════════════════════════════════════════
# Architecture 3: GraphSAGE — Inductive / large-graph friendly
# Best for: Large graphs, inductive settings (unseen nodes at test time)
# ══════════════════════════════════════════════════════════════════════════════

class GraphSAGE(nn.Module):
    """
    GraphSAGE (Hamilton et al., 2017).
    Aggregates neighbor features via mean/max/LSTM — scales to large graphs.
    Inductive: can generalize to unseen nodes not in the training graph.

    Args:
        in_channels:     Dimension of input node features.
        hidden_channels: Hidden layer dimension.
        out_channels:    Number of output classes.
        num_layers:      Number of SAGE layers.
        dropout:         Dropout rate.
        task:            'node' or 'graph' classification.
    """
    def __init__(
        self, in_channels: int, hidden_channels: int, out_channels: int,
        num_layers: int = 3, dropout: float = 0.5, task: str = "node",
    ):
        super().__init__()
        self.task = task
        self.dropout = dropout

        self.convs = nn.ModuleList()
        self.bns = nn.ModuleList()

        for i in range(num_layers):
            in_ch = in_channels if i == 0 else hidden_channels
            self.convs.append(SAGEConv(in_ch, hidden_channels))
            self.bns.append(nn.BatchNorm1d(hidden_channels))

        self.classifier = nn.Linear(hidden_channels, out_channels)

    def forward(self, x: torch.Tensor, edge_index: torch.Tensor,
                batch: Optional[torch.Tensor] = None) -> torch.Tensor:
        for conv, bn in zip(self.convs, self.bns):
            x = F.relu(bn(conv(x, edge_index)))
            x = F.dropout(x, p=self.dropout, training=self.training)

        if self.task == "graph":
            x = global_mean_pool(x, batch)

        return self.classifier(x)


# ══════════════════════════════════════════════════════════════════════════════
# Architecture 4: GIN — Graph Isomorphism Network
# Best for: Graph classification, maximally expressive (Weisfeiler-Leman equiv.)
# ══════════════════════════════════════════════════════════════════════════════

class GIN(nn.Module):
    """
    Graph Isomorphism Network (Xu et al., 2019).
    Most expressive GNN for graph-level tasks in the WL hierarchy.
    Aggregates by: h_v = MLP((1 + eps) * h_v + sum(neighbors))

    Args:
        in_channels:     Dimension of input node features.
        hidden_channels: Hidden dimension for each MLP layer.
        out_channels:    Number of output classes.
        num_layers:      Number of GIN layers (3-5 for graph classification).
        dropout:         Dropout rate.
    """
    def __init__(
        self, in_channels: int, hidden_channels: int, out_channels: int,
        num_layers: int = 4, dropout: float = 0.5,
    ):
        super().__init__()
        self.dropout = dropout
        self.convs = nn.ModuleList()
        self.bns = nn.ModuleList()

        for i in range(num_layers):
            in_ch = in_channels if i == 0 else hidden_channels
            mlp = nn.Sequential(
                nn.Linear(in_ch, hidden_channels),
                nn.BatchNorm1d(hidden_channels),
                nn.ReLU(),
                nn.Linear(hidden_channels, hidden_channels),
            )
            self.convs.append(GINConv(mlp, train_eps=True))
            self.bns.append(nn.BatchNorm1d(hidden_channels))

        # Jumping Knowledge: concat all layer outputs before classifier
        self.classifier = nn.Sequential(
            nn.Linear(hidden_channels * num_layers, hidden_channels),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_channels, out_channels),
        )

    def forward(self, x: torch.Tensor, edge_index: torch.Tensor,
                batch: torch.Tensor) -> torch.Tensor:
        layer_outputs: list[torch.Tensor] = []
        for conv, bn in zip(self.convs, self.bns):
            x = F.relu(bn(conv(x, edge_index)))
            x = F.dropout(x, p=self.dropout, training=self.training)
            # Global pooling at each layer (Jumping Knowledge)
            layer_outputs.append(global_add_pool(x, batch))

        # Concatenate all layers' pooled outputs
        x = torch.cat(layer_outputs, dim=1)
        return self.classifier(x)


# ══════════════════════════════════════════════════════════════════════════════
# Training helpers
# ══════════════════════════════════════════════════════════════════════════════

def train_epoch(model: nn.Module, loader: "DataLoader",
                optimizer: "torch.optim.Optimizer",
                criterion: nn.Module, device: str) -> float:
    model.train()
    total_loss = 0.0
    for data in loader:
        data = data.to(device)
        optimizer.zero_grad()
        if model.__class__.__name__ == "GIN" or getattr(model, "task", "") == "graph":
            out = model(data.x, data.edge_index, data.batch)
        else:
            out = model(data.x, data.edge_index)
            if hasattr(data, "train_mask"):
                out = out[data.train_mask]
                target = data.y[data.train_mask]
            else:
                target = data.y
            loss = criterion(out, target)
            loss.backward()
            optimizer.step()
            total_loss += float(loss)
            continue
        loss = criterion(out, data.y)
        loss.backward()
        optimizer.step()
        total_loss += float(loss)
    return total_loss / len(loader)


@torch.no_grad()
def evaluate(model: nn.Module, loader: "DataLoader", device: str) -> float:
    model.eval()
    correct = total = 0
    for data in loader:
        data = data.to(device)
        if model.__class__.__name__ == "GIN" or getattr(model, "task", "") == "graph":
            out = model(data.x, data.edge_index, data.batch)
            pred = out.argmax(dim=1)
            correct += int((pred == data.y).sum())
            total += data.y.size(0)
        else:
            out = model(data.x, data.edge_index)
            if hasattr(data, "test_mask"):
                pred = out[data.test_mask].argmax(dim=1)
                correct += int((pred == data.y[data.test_mask]).sum())
                total += int(data.test_mask.sum())
            else:
                pred = out.argmax(dim=1)
                correct += int((pred == data.y).sum())
                total += data.y.size(0)
    return correct / total if total > 0 else 0.0


# ══════════════════════════════════════════════════════════════════════════════
# Architecture selection guide
# ══════════════════════════════════════════════════════════════════════════════

ARCHITECTURE_GUIDE = """
GNN Architecture Selection Guide — BMAD DL Lifecycle
─────────────────────────────────────────────────────
Task: Node classification
  Homophilic graph (similar nodes connected)  → GCN
  Attention needed (noisy neighbors)          → GAT
  Large / dynamic / inductive graph           → GraphSAGE

Task: Graph classification
  Standard accuracy                           → GraphSAGE or GCN + global pool
  Maximum expressiveness                      → GIN (recommended)
  Edge features matter                        → GAT with edge_attr

Quick model size guide:
  Small dataset  (<1K graphs)  → 2 layers, hidden=64
  Medium dataset (1K–50K)      → 3 layers, hidden=128
  Large dataset  (50K+)        → 4-5 layers, hidden=256, mini-batch DataLoader

Typical hyperparameter ranges:
  hidden_channels: 64, 128, 256
  num_layers:      2, 3, 4
  dropout:         0.3 – 0.6
  heads (GAT):     4, 8
  learning_rate:   0.001 – 0.01
"""

if __name__ == "__main__":
    print(ARCHITECTURE_GUIDE)
