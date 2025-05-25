import 'package:calmcampus/utilities/api_check.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static late IO.Socket socket;

  static void initializeSocket(String userId) {
    socket = IO.io(
      "$baseUrl", // Replace with your server URL
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'userId': userId}) // userId expected by NestJS backend
          .build(),
    );

    socket.connect();

    socket.onConnect((_) => print('✅ Socket connected'));
    socket.onDisconnect((_) => print('❌ Socket disconnected'));
    socket.onConnectError((err) => print('⚠️ Connect error: $err'));
    socket.onError((err) => print('⚠️ General error: $err'));
  }

  static void listenForMessages(Function(dynamic) onMessageReceived) {
    socket.on('newMessage', (data) {
      print("📩 New message received: $data");
      onMessageReceived(data);
    });
  }

  static void sendMessage(String senderId, String receiverId, String content) {
    socket.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  static void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
