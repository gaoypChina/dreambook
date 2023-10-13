// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dreambook/src/ui/pages/shared/code_space/code_space.dart';
import 'package:dreambook/src/ui/pages/shared/code_space/code_span.dart';
import 'package:dreambook/src/ui/pages/shared/shared_code_view.dart';
import 'package:dreambook/src/ui/pages/shared/tiles/menu_tile.dart';
import 'package:dreambook/src/ui/pages/shared/tiles/slidable_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_indicator.g.dart';

final progressIndicatorItem = CodeItem(
  title: 'Progress Indicator',
  code: const TheCode(),
  widget: const TheWidget(),
);

enum IndicatorType {
  circular('CircularProgressIndicator'),
  linear('LinearProgressIndicator'),
  ;

  const IndicatorType(this.code);
  final String code;
}

class IndicatorConfig {
  IndicatorConfig({
    this.type = IndicatorType.circular,
    this.value = 0,
    this.loading = true,
    this.minHeight = 4,
    this.borderRadius = 2,
    this.strokeWidth = 4.0,
    this.strokeCap = StrokeCap.round,
  });
  final IndicatorType type;
  final double value;
  final bool loading;
  final double minHeight;
  final double borderRadius;
  final double strokeWidth;
  final StrokeCap strokeCap;

  IndicatorConfig copyWith({
    IndicatorType? type,
    double? value,
    bool? loading,
    double? minHeight,
    double? borderRadius,
    double? strokeWidth,
    StrokeCap? strokeCap,
  }) {
    return IndicatorConfig(
      type: type ?? this.type,
      value: value ?? this.value,
      loading: loading ?? this.loading,
      minHeight: minHeight ?? this.minHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
    );
  }
}

@riverpod
class Config extends _$Config {
  @override
  IndicatorConfig build() => IndicatorConfig();

  void change(IndicatorConfig config) {
    state = config;
  }
}

class TheCode extends ConsumerWidget {
  const TheCode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    return CodeSpace([
      StaticCodes.material,
      '',
      '${config.type.code} (',
      if (!config.loading) '  value: ${config.value.toStringAsFixed(2)},',
      ...switch (config.type) {
        IndicatorType.circular => [
          '  strokeWidth: ${config.strokeWidth.toStringAsFixed(0)}',
          '  strokeCap: StrokeCap.${config.strokeCap.name},',
        ],
        IndicatorType.linear => [
            '  minHeight: ${config.minHeight.toStringAsFixed(0)},',
            '  borderRadius: BorderRadius.circular(${config.borderRadius.toStringAsFixed(0)}),',
          ],
      },
      ')',
    ]);
  }
}

class TheWidget extends ConsumerWidget {
  const TheWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final isLinear = config.type == IndicatorType.linear;
    final isCircular = config.type == IndicatorType.circular;
    return WidgetWithConfiguration(
      content: switch (config.type) {
        IndicatorType.circular => CircularProgressIndicator(
            value: config.loading ? null : config.value,
            strokeCap: config.strokeCap,
            strokeWidth: config.strokeWidth,
          ),
        IndicatorType.linear => LinearProgressIndicator(
            value: config.loading ? null : config.value,
            minHeight: config.minHeight,
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
        // pattern =>
      },
      configs: [
        MenuTile<IndicatorType>(
          title: 'type',
          items: IndicatorType.values,
          current: config.type,
          onTap: (t) {
            ref.read(configProvider.notifier).change(config.copyWith(type: t));
          },
          contentBuilder: (t) => t.name,
        ),
        SwitchListTile(
          title: const Text('loading'),
          value: config.loading,
          onChanged: (t) {
            ref
                .read(configProvider.notifier)
                .change(config.copyWith(loading: t));
          },
        ),
        if (!config.loading)
          SlidableTile(
            title: 'Value',
            value: config.value,
            onChanged: (t) {
              ref
                  .read(configProvider.notifier)
                  .change(config.copyWith(value: t));
            },
          ),
        if (isLinear)
          SlidableTile(
            title: 'minHeight',
            value: config.minHeight,
            min: 1,
            max: 24,
            onChanged: (t) {
              ref
                  .read(configProvider.notifier)
                  .change(config.copyWith(minHeight: t));
            },
          ),
        if (isLinear)
          SlidableTile(
            title: 'border radius',
            value: config.borderRadius,
            min: 0,
            max: 24,
            onChanged: (t) {
              ref
                  .read(configProvider.notifier)
                  .change(config.copyWith(borderRadius: t));
            },
          ),
        if (isCircular)
          SlidableTile(
            title: 'stroke width',
            value: config.strokeWidth,
            min: 0,
            max: 12,
            onChanged: (t) {
              ref
                  .read(configProvider.notifier)
                  .change(config.copyWith(strokeWidth: t));
            },
          ),
        if (isCircular)
          MenuTile(
              title: 'stroke cap',
              items: StrokeCap.values,
              current: config.strokeCap,
              onTap: (t) {
                ref
                    .read(configProvider.notifier)
                    .change(config.copyWith(strokeCap: t));
              },
              contentBuilder: (t) => t.name),
      ],
    );
  }
}
