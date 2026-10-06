enum ViewState { idle, loading, success, error }

extension ViewStateX on ViewState {
  bool get isLoading => this == ViewState.loading;
  bool get isSuccess => this == ViewState.success;
  bool get isError => this == ViewState.error;
  bool get isIdle => this == ViewState.idle;
}

enum ToastType { success, error, warning, general }

enum Flavor {
  dev('dev', 'Colab Health Dev'),
  stage('stage', 'Colab Health Stage'),
  prod('prod', 'Colab Health');

  final String value;
  final String appName;
  const Flavor(this.value, this.appName);
}

enum HttpMethod { get, post, put, patch, delete }

enum MetricType {
  steps('Steps'),
  calories('Calories'),
  sleep('Sleep'),
  heart('Heart Rate');

  final String label;
  const MetricType(this.label);
}

enum SleepStageType {
  awake('Awake'),
  light('Light'),
  rem('REM'),
  deep('Deep');

  final String label;
  const SleepStageType(this.label);
}

enum ChartRange {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  final String label;
  const ChartRange(this.label);
}

enum TrackingPermission { granted, denied, restricted, unknown }

enum HealthStepsAvailability {

  available,

  needsInstall,

  notSupported,
}

enum StepsDataStatus {

  ok,

  needsInstall,

  needsPermission,
}
