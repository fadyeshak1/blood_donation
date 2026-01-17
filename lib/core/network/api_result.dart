sealed class ApiResult<T> {
  const ApiResult();
}

/// Success result containing data
class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

/// Failure result containing error message
class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  
  const ApiFailure(this.message, {this.statusCode});
}