enum DimensionUnit {
  px,
  rem,
  em,
  percent,
  none;

  String get label {
    switch (this) {
      case DimensionUnit.px:
        return 'px';
      case DimensionUnit.rem:
        return 'rem';
      case DimensionUnit.em:
        return 'em';
      case DimensionUnit.percent:
        return '%';
      case DimensionUnit.none:
        return '';
    }
  }

  static DimensionUnit fromString(String value) {
    switch (value.toLowerCase()) {
      case 'px':
        return DimensionUnit.px;
      case 'rem':
        return DimensionUnit.rem;
      case 'em':
        return DimensionUnit.em;
      case '%':
      case 'percent':
        return DimensionUnit.percent;
      default:
        return DimensionUnit.none;
    }
  }
}

class Dimension {
  final double value;
  final DimensionUnit unit;

  const Dimension(this.value, this.unit);

  const Dimension.px(double val) : this(val, DimensionUnit.px);
  const Dimension.rem(double val) : this(val, DimensionUnit.rem);
  const Dimension.em(double val) : this(val, DimensionUnit.em);
  const Dimension.percent(double val) : this(val, DimensionUnit.percent);
  const Dimension.none(double val) : this(val, DimensionUnit.none);

  @override
  String toString() {
    if (unit == DimensionUnit.none) {
      if (value == value.roundToDouble()) {
        return value.round().toString();
      }
      return value.toString();
    }
    final formattedValue = value == value.roundToDouble() ? value.round().toString() : value.toString();
    return '$formattedValue${unit.label}';
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit.name,
      };

  factory Dimension.fromJson(Map<String, dynamic> json) {
    return Dimension(
      (json['value'] as num).toDouble(),
      DimensionUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => DimensionUnit.none,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dimension &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          unit == other.unit;

  @override
  int get hashCode => value.hashCode ^ unit.hashCode;
}
