import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

bool isNetworkError(Object error) {
  return error is http.ClientException ||
      error is SocketException ||
      error is TimeoutException;
}
