import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:zic_flutter/core/models/message.dart';

class SocketService {
  IO.Socket? socket;
  Function(Message)? onMessageReceived;

  void connect(String baseUrl) {
    socket = IO.io('$baseUrl/chat', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket?.on('connect', (_) {
      print('Socket connected');
    });

    socket?.on('receiveMessage', (data) {
      print('Message received from server: $data');
      if (onMessageReceived != null) {
        onMessageReceived!(Message.fromJson(data));
      }
    });

    socket?.on('disconnect', (_) {
      print('Socket disconnected');
    });

    socket?.on('connect_error', (data) => print("connect_error: $data"));
    socket?.on('connect_timeout', (data) => print("connect_timeout: $data"));
    socket?.on('error', (data) => print("error: $data"));
    socket?.on('reconnect', (data) => print("reconnect: $data"));
    socket?.on('reconnect_attempt', (data) => print("reconnect_attempt: $data"));
    socket?.on('reconnecting', (data) => print("reconnecting: $data"));
    socket?.on('reconnect_error', (data) => print("reconnect_error: $data"));
    socket?.on('reconnect_failed', (data) => print("reconnect_failed: $data"));
    socket?.on('ping', (data) => print("ping: $data"));
    socket?.on('pong', (data) => print("pong: $data"));
  }

  void disconnect() {
    socket?.disconnect();
  }

  void joinRoom(String roomId) {
  print("Joining room: $roomId");
  socket?.emit('joinRoom', {'roomId': roomId});
}

  void leaveRoom(String roomId) {
    socket?.emit('leaveRoom', {'roomId': roomId});
  }

  void sendMessage(Map<String, Object> message) {
    socket?.emit('sendMessage', message);
  }
}