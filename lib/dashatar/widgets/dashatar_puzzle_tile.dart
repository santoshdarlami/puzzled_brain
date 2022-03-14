import 'dart:async';
import 'dart:math';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/dashatar/dashatar.dart';
import 'package:very_good_slide_puzzle/dashatar/widgets/dashtar_puzzle_tile_back.dart';
import 'package:very_good_slide_puzzle/dashatar/widgets/dashtar_puzzle_tile_front.dart';
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

abstract class _TileSize {
  static double small = 75;
  static double medium = 100;
  static double large = 112;
}

/// {@template dashatar_puzzle_tile}
/// Displays the puzzle tile associated with [tile]
/// based on the puzzle [state].
/// {@endtemplate}
class DashatarPuzzleTile extends StatefulWidget {
  /// {@macro dashatar_puzzle_tile}
  const DashatarPuzzleTile({
    Key? key,
    required this.tile,
    required this.state,
    AudioPlayerFactory? audioPlayer,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  /// The state of the puzzle.
  final PuzzleState state;

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<DashatarPuzzleTile> createState() => DashatarPuzzleTileState();
}

/// The state of [DashatarPuzzleTile].
@visibleForTesting
class DashatarPuzzleTileState extends State<DashatarPuzzleTile>
    with SingleTickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  late final Timer _timer;

  /// The controller that drives [_scale] animation.
  // late AnimationController _controller;
  // late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

/*    _controller = AnimationController(
      vsync: this,
      duration: PuzzleThemeAnimationDuration.puzzleTileScale,
    );*/

/*    _scale = Tween<double>(begin: 1, end: 0.94).a  CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 1, curve: Curves.easeInOut),
      ),
    );*/

    // Delay the initialization of the audio player for performance reasons,
    // to avoid dropping frames when the theme is changed.
    _timer = Timer(const Duration(seconds: 1), () {
      _audioPlayer = widget._audioPlayerFactory()
        ..setAsset('assets/audio/tile_move.mp3');
    });
  }

  var isCardFlipped = false;

  @override
  Widget build(BuildContext context) {
    bool movable;
    if (widget.state.puzzle.isTileMovable(widget.tile)) {
      movable = true;
    } else {
      movable = false;
    }
    FlipDirection direction;
    if (widget.state.puzzle.isTileMovableVertically(widget.tile)) {
      direction = FlipDirection.VERTICAL;
    } else {
      direction = FlipDirection.HORIZONTAL;
    }
    final size = widget.state.puzzle.getDimension();
    // final theme = context.select((DashatarThemeBloc bloc) => bloc.state.theme);
    final status =
        context.select((DashatarPuzzleBloc bloc) => bloc.state.status);
    final hasStarted = status == DashatarPuzzleStatus.started;
    final puzzleIncomplete =
        context.select((PuzzleBloc bloc) => bloc.state.puzzleStatus) ==
            PuzzleStatus.incomplete;

/*    final puzzleRestart = context.select(
      (DashatarPuzzleBloc bloc) => bloc.isRestart(),
    );*/
    final movementDuration = status == DashatarPuzzleStatus.loading
        ? const Duration(milliseconds: 800)
        : const Duration(milliseconds: 370);

    final canPress = hasStarted && puzzleIncomplete;

    void flipRandomly(Tile tile) {
      final random = Random();
      if (random.nextInt(15).isEven) {
        isCardFlipped = false;
      } else {
        isCardFlipped = true;
      }
    }

    if (status == DashatarPuzzleStatus.loading) {
      flipRandomly(widget.tile);
    }
    if (widget.state.puzzle.isComplete()) {
      setState(() {
        isCardFlipped = false;
      });
    }
    final flipCard = FlipCard(
      front: !isCardFlipped ? Front(tile: widget.tile) : Back(tile: widget.tile)
      /*Card(
      color: PuzzleColors.white,
      child: Center(
        child: Text(
          widget.tile.value.toString(),
          // semanticsLabel: context.l10n.puzzleTileLabelText(
          //   widget.tile.value.toString(),
          //   widget.tile.currentPosition.x.toString(),
          //   widget.tile.currentPosition.y.toString(),
          // ),
          style: const TextStyle(
            color: PuzzleColors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    )*/
      ,
      back: isCardFlipped ? Back(tile: widget.tile) : Front(tile: widget.tile)
      /*widget.state.puzzle.isComplete() && puzzleRestart
          ? Card(
              color: Colors.black,
              child: Center(
                child: Text(
                  widget.tile.value.toString(),
                  semanticsLabel: context.l10n.puzzleTileLabelText(
                    widget.tile.value.toString(),
                    widget.tile.currentPosition.x.toString(),
                    widget.tile.currentPosition.y.toString(),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : */
      ,
      speed: 450,
      flipOnTouch: canPress && movable,
      direction: direction,
      onFlip: canPress
          ? () {
              isCardFlipped = !isCardFlipped;
              context.read<PuzzleBloc>().add(TileTapped(widget.tile));
              unawaited(_audioPlayer?.replay());
            }
          : null,
    );

    if (!widget.state.puzzle.isComplete()) {
      setState(() {
        flipCard.controller?.state?.toggleCard();
        flipCard.controller?.controller?.forward();
        print('complete');
      });
    }
    return AudioControlListener(
      audioPlayer: _audioPlayer,
      child: AnimatedAlign(
        alignment: FractionalOffset(
          (widget.tile.currentPosition.x - 1) / (size - 1),
          (widget.tile.currentPosition.y - 1) / (size - 1),
        ),
        duration: movementDuration,
        curve: Curves.easeIn,
        child: ResponsiveLayoutBuilder(
          small: (_, child) => SizedBox.square(
            key: Key('dashatar_puzzle_tile_small_${widget.tile.value}'),
            dimension: _TileSize.small,
            child: child,
          ),
          medium: (_, child) => SizedBox.square(
            key: Key('dashatar_puzzle_tile_medium_${widget.tile.value}'),
            dimension: _TileSize.medium,
            child: child,
          ),
          large: (_, child) => SizedBox.square(
            key: Key('dashatar_puzzle_tile_large_${widget.tile.value}'),
            dimension: _TileSize.large,
            child: child,
          ),
          // child: (_) => MouseRegion(
/*            onEnter: (_) {
              if (canPress) {
                _controller.forward();
              }
            },
            onExit: (_) {
              if (canPress) {
                _controller.reverse();
              }
            },*/
          child: (_) =>
              // widget.state.puzzle.isComplete() ? flipCard.front : flipCard,
              flipCard,
          // ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }
}
