import 'dart:async';
import 'dart:io';

bool isNetworkError(Object error) {
  return error is SocketException || error is TimeoutException;
}
