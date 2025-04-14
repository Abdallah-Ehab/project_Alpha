class Result<T>{

  String? errorMessage;
  T? result;

  Result.success({this.result}): errorMessage = null;
  Result.failure({this.errorMessage}): result = null;

}