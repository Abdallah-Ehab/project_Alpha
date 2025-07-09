part of 'storage_cubit.dart';

abstract class StorageState {}

class StorageInitial extends StorageState {}

class StorageReady extends StorageState {}

class StorageLoading extends StorageState {}

class StorageSuccess extends StorageState {
  final String message;

  StorageSuccess(this.message);
}

class StorageError extends StorageState {
  final String error;

  StorageError(this.error);
}
