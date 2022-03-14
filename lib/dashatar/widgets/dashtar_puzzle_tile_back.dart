import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/dashatar/widgets/dashtar_puzzle_tile_front.dart';
import 'package:very_good_slide_puzzle/models/tile.dart';

class Back extends StatelessWidget {
  // const Front({Key? key}) : super(key: key);
  ///we get the number from the tile parameter
  const Back({Key? key, required this.tile}) : super(key: key);

  final Tile tile;

  @override
  Widget build(BuildContext context) {
    final isCorrectTile = tile.correctPosition == tile.currentPosition;
    return isCorrectTile
        ? Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: PuzzleColors.primaryGreen,
          )
        : Card(
            shape: RoundedRectangleBorder(
              // side: const BorderSide(color: PuzzleColors.primaryYellow),
              borderRadius: BorderRadius.circular(12),
            ),
            color: PuzzleColors.primaryYellow,
          );
  }
}
