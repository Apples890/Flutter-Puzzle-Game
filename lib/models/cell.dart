
enum CellVisibility { hidden, revealed, flagged }

class Cell {
  final bool isBomb;
  final int value;
  CellVisibility visibility;

  Cell({
    required this.isBomb,
    required this.value,
    this.visibility = CellVisibility.hidden,
  });
}
