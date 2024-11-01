import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/views/todo_view.dart';
import 'package:http/http.dart' as http;

// Hàm main là điểm bắt đầu của ứng dụng
void main() {
  runApp(const MainApp()); // Chạy ứng dụng với widget MainApp
}

// Widget MainApp là widget gốc của ứng dụng, sử dụng StatelessWidget
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng full-stack Flutter đơn giản',
      home: TodoView(),
    );
  }
}

// Widget MyHomePage là trang chính của ứng dụng, sử dụng StatefulWidget
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Lớp state cho MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  // Controller để lấy dữ liệu từ Widget TextField
  final nameController = TextEditingController();

  // Biến để lưu thông điệp phản hồi từ server
  String responseMessage = '';

  // Sử dụng địa chỉ IP thích hợp cho backend
  // Do Androi Emulator sử dụng địc chỉ 10.0.2.2 để truy cập vào localhost
  // của máy chủ thay thay vì localhost hoặc 127.0.0.1
  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
      // hoặc sử dụng mạng Lan neus cần
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
      // cho emulator
      // return 'http://10.0.2.2:8080'; cho thiết bị thật khi truy cập qua LAN
    } else {
      return 'http://localhost:8080';
    }
  }

  // Hàm để gửi tới server
  Future<void> sendData() async {
    // Lấy tên và năm sinh từ TextField
    final name = nameController.text;
    // Xóa nội dung trong controller
    nameController.clear();

    // Endpoint submit
    final url = Uri.parse('http://localhost:8080/api/v1/submit');

    try {
      // Gửi yêu cầu POST tới server
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // Kiểm tra nếu phản hồi có nội dung
      if (response.statusCode == 200) {
        // Giải mã phản hồi từ server
        final data = json.decode(response.body);
        // Cập nhật trạng thái thông điệp nhận được từ server
        setState(() {
          responseMessage = data['message'] +
              (data.containsKey('age') ? ', Tuổi: ${data['age']}' : '');
        });
      } else {
        // Phản hồi không thành công
        setState(() {
          responseMessage = 'Server trả về mã lỗi: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Xử lý lỗi kết nối hoặc lỗi khác
      setState(() {
        responseMessage = 'Đã xảy ra lỗi: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ứng dụng full-stack Flutter đơn giản',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendData,
              child: const Text('Gửi'),
            ),
            const SizedBox(height: 20),
            // Hiển thị thông điệp phản hồi từ server
            Text(
              responseMessage,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }
}
