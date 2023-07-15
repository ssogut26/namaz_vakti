part of '../view/compass_qibla.dart';

class _Degree extends StatelessWidget {
  const _Degree({
    required this.qiblahDirection,
  });

  final QiblahDirection qiblahDirection;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      child: Text(
        '${qiblahDirection.direction.toStringAsFixed(2)}°',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _Needle extends StatelessWidget {
  const _Needle({
    required this.qiblahDirection,
  });

  final QiblahDirection qiblahDirection;

  @override
  Widget build(BuildContext context) {
    final needleSvg = SvgPicture.asset(
      AppConstants.needle,
      height: 300,
    );
    return AnimatedRotation(
      turns: qiblahDirection.qiblah * pi / 180,
      duration: const Duration(seconds: 1),
      child: needleSvg,
    );
  }
}

class _Compass extends StatelessWidget {
  const _Compass({
    required this.qiblahDirection,
  });

  final QiblahDirection qiblahDirection;

  @override
  Widget build(BuildContext context) {
    final compassSvg = SvgPicture.asset(
      AppConstants.compass,
      width: MediaQuery.of(context).size.width * 0.9,
    );
    return AnimatedRotation(
      turns: qiblahDirection.direction * pi / 180 - 1,
      duration: const Duration(seconds: 1),
      child: compassSvg,
    );
  }
}
