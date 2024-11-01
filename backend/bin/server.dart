import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'routes/todo_router.dart';

// Cấu hình các routes
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/api/v1/check', _checkHandler)
  ..get('/echo/<message>', _echoHandler)
  ..post('/api/v1/submit', _submitHandler);

// Header mặc định cho dữ liệu trả về dưới dạng JSON
final _headers = {'Content-Type': 'application/json'};

// Xử lý các yêu cầu đến các đường dẫn không được định nghĩa (404 Not Found).
Response _notFoundHandler(Request req) {
  return Response.notFound(
    json.encode({'error': 'Không tìm thấy đường dẫn "${req.url}" trên server'}),
    headers: _headers,
  );
}

// Hàm xử lý các yêu cầu gốc tại đường dẫn '/'
Response _rootHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Hello, World!'}),
    headers: _headers,
  );
}

// Hàm xử lý yêu cầu tại đường dẫn '/api/v1/check'
Response _checkHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Chào mừng bạn đến với ứng dụng web di động'}),
    headers: _headers,
  );
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

// Xử lý yêu cầu POST tại '/api/v1/submit'
Future<Response> _submitHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    final data = json.decode(payload);
    final name = data['name'] as String?;

    if (name != null && name.isNotEmpty) {
      return Response.ok(
        json.encode({'message': 'Chào mừng $name!'}),
        headers: _headers,
      );
    } else {
      return Response.badRequest(
        body: json.encode({'message': 'Server không nhận được tên của bạn.'}),
        headers: _headers,
      );
    }
  } catch (e) {
    return Response.badRequest(
      body: json
          .encode({'message': 'Yêu cầu không hợp lệ. Lỗi: ${e.toString()}'}),
      headers: _headers,
    );
  }
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;

  final corsHeader = createMiddleware(
    requestHandler: (req) {
      if (req.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': 'http://localhost:8081',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, HEAD',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }
      return null;
    },
    responseHandler: (res) {
      return res.change(headers: {
        'Access-Control-Allow-Origin': 'http://localhost:8081',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, HEAD',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    },
  );

  final todoRouter = TodoRouter();
  _router.mount('/api/v1/', todoRouter.router);

  final handler = Pipeline()
      .addMiddleware(corsHeader)
      .addMiddleware(logRequests())
      .addHandler(_router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server đang chạy tại http://${server.address.host}:${server.port}');
}
