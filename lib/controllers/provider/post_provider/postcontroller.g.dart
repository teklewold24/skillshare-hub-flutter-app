// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postcontroller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Postcontroller)
const postcontrollerProvider = PostcontrollerProvider._();

final class PostcontrollerProvider
    extends $NotifierProvider<Postcontroller, PostModel> {
  const PostcontrollerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postcontrollerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postcontrollerHash();

  @$internal
  @override
  Postcontroller create() => Postcontroller();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostModel>(value),
    );
  }
}

String _$postcontrollerHash() => r'dc185f35c8d1a612523d4976f7924ff85f4f49b1';

abstract class _$Postcontroller extends $Notifier<PostModel> {
  PostModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PostModel, PostModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PostModel, PostModel>,
              PostModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
