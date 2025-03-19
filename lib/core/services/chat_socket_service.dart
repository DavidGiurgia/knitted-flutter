import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:zic_flutter/core/models/message.dart';

class ChatSocketService {
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;

  IO.Socket? socket;
  Function(String roomId, DateTime lastActivity, Message lastMessage)? onRoomUpdated;
  Function(Message message)? onMessageReceived;
  Function(String roomId, int unreadCount)? onUnreadCountUpdated;
  Function(String userId, String roomId)? onUserJoined;
  Function(String userId, String roomId)? onUserLeft;

  ChatSocketService._internal();

  Future<void> connect(String baseUrl) async {
    if (isConnected) {
      print('Socket already connected');
      return;
    }

    final Completer<void> completer = Completer<void>();

    try {
      socket = IO.io('$baseUrl/chat', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 2000,
      });

      _setupSocketListeners(completer);

      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Socket connection timeout');
          throw TimeoutException("Connection timed out. Please check your internet connection.");
        },
      );
    } catch (error) {
      print('Socket connection error: $error');
      rethrow;
    }
  }

  void _setupSocketListeners(Completer<void> completer) {
    socket?.on('connect', (_) {
      print('Socket connected');
      if (!completer.isCompleted) completer.complete();
    });

    socket?.on('connect_error', (error) {
      print('Socket connection error: $error');
      if (!completer.isCompleted) completer.completeError(error);
    });

    socket?.on('receiveMessage', (data) {
      if (data != null && data is Map<String, dynamic>) {
        print('Message received from server: $data');
        onMessageReceived?.call(Message.fromJson(data));
      } else {
        print('Invalid message data received: $data');
      }
    });

    socket?.on('roomUpdated', (data) {
      if (data != null && data is Map<String, dynamic> && data['lastMessage'] != null) {
        print("Room updated: $data");
        onRoomUpdated?.call(
          data['roomId'],
          DateTime.parse(data['lastActivity']),
          Message.fromJson(data['lastMessage']),
        );
      } else {
        print('Invalid room update data received: $data');
      }
    });

    socket?.on('unreadCountUpdated', (data) {
      if (data != null && data is Map<String, dynamic>) {
        print("Unread count updated: $data");
        onUnreadCountUpdated?.call(data['roomId'], data['unreadCount']);
      } else {
        print('Invalid unread count data received: $data');
      }
    });

    socket?.on('userJoined', (data) {
      if(data != null && data is Map<String, dynamic>){
        print('User joined room: $data');
        onUserJoined?.call(data['userId'], data['roomId']);
      } else {
        print("Invalid user joined data received: $data");
      }
    });

    socket?.on('userLeft', (data) {
      if(data != null && data is Map<String, dynamic>){
        print('User left room: $data');
        onUserLeft?.call(data['userId'], data['roomId']);
      } else {
        print("Invalid user left data received: $data");
      }
    });

    socket?.on('disconnect', (_) => print('Socket disconnected'));
    socket?.on('reconnect', (_) => print('Socket reconnected'));
    socket?.on('reconnect_failed', (error) => print('Socket reconnection failed: $error'));
    socket?.on('connect_timeout', (_) => print('Socket connection timed out'));
  }

  void disconnect() {
    if (isConnected) {
      socket?.disconnect();
      socket = null;
      print('Socket manually disconnected');
    }
  }

  bool get isConnected => socket != null && (socket!.connected || socket!.active);

  void joinRoom(String roomId) {
    if (isConnected) {
      print("Joining room: $roomId");
      socket?.emit('joinRoom', {'roomId': roomId});
    } else {
      print('Socket is not connected, cannot join room');
    }
  }

  void leaveRoom(String roomId) {
    if (isConnected) {
      socket?.emit('leaveRoom', {'roomId': roomId});
    } else {
      print('Socket is not connected, cannot leave room');
    }
  }

  void sendMessage(Map<String, Object> message) {
    if (isConnected) {
      socket?.emit('sendMessage', message);
    } else {
      print('Socket is not connected, cannot send message');
    }
  }

  void markMessageAsRead(String messageId, String roomId, String userId) {
    if (isConnected) {
      socket?.emit('markMessageAsRead', {
        'messageId': messageId,
        'roomId': roomId,
        'userId': userId,
      });
    } else {
      print('Socket is not connected, cannot mark message as read');
    }
  }
}