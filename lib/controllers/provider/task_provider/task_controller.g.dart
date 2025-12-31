// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskController)
const taskControllerProvider = TaskControllerProvider._();

final class TaskControllerProvider
    extends $NotifierProvider<TaskController, TaskModel> {
  const TaskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskControllerHash();

  @$internal
  @override
  TaskController create() => TaskController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskModel>(value),
    );
  }
}

String _$taskControllerHash() => r'e8e78dd1b48a588fca4810347923897bafcbcfad';

abstract class _$TaskController extends $Notifier<TaskModel> {
  TaskModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TaskModel, TaskModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskModel, TaskModel>,
              TaskModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
