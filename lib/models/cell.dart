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

  Cell clone() {
    return Cell(isBomb: isBomb, value: value, visibility: visibility);
  }
}
