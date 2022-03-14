import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/models/tile.dart';

class Front extends StatelessWidget {
  // const Front({Key? key}) : super(key: key);
  ///we get the number from the tile parameter
  const Front({Key? key, required this.tile}) : super(key: key);

  final Tile tile;

  @override
  Widget build(BuildContext context) {
    final isCorrectTile = tile.correctPosition == tile.currentPosition;

    return Card(
      color: isCorrectTile ? PuzzleColors.primaryGreen : PuzzleColors.primary1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          tile.value.toString(),
          style: const TextStyle(
            color: PuzzleColors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
