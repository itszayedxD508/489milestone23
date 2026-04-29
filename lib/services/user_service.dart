import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class UserService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromMap(data);
        if (user.id != null) {
          await _saveUserId(user.id!);
        }
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Login Error: $e");
      return null;
    }
  }

  Future<User?> signup(
    String email,
    String password, {
    String? username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromMap(data);
        if (user.id != null) {
          await _saveUserId(user.id!);
        }
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Signup Error: $e");
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    return null; // Deprecated
  }

  Future<void> _saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', id);
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('current_user_id');
      if (id != null) {
        final response = await http.get(Uri.parse('$_baseUrl/users/$id'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return User.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Get Current User Error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  Future<void> addXp(User user, int xp) async {
    if (user.id == null) return;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/${user.id}/xp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'xp': xp}),
      );
      if (response.statusCode != 200) {
        if (kDebugMode) print("Add XP Error: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print("Add XP Error: $e");
    }
  }

  // --- NEW FRIEND REQUEST API ---

  Future<List<User>> searchUserByUsername(String username) async {
    if (username.isEmpty) return [];
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/search/$username'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => User.fromMap(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("Search Error: $e");
    }
    return [];
  }

  Future<bool> sendFriendRequest(String senderId, String receiverId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'senderId': senderId, 'receiverId': receiverId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print("Send Request Error: $e");
    }
    return false;
  }

  Future<List<User>> getFriendRequests(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friend-requests/$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => User.fromMap(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("Get Friend Requests Error: $e");
    }
    return [];
  }

  Future<bool> acceptRequest(String userId, String senderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accept-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'senderId': senderId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print("Accept Request Error: $e");
    }
    return false;
  }

  Future<bool> rejectRequest(String userId, String senderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reject-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'senderId': senderId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print("Reject Request Error: $e");
    }
    return false;
  }

  Future<List<User>> getFriends(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/friends/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => User.fromMap(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("Get Friends Error: $e");
    }
    return [];
  }

  // --- API BASED CHAT ---

  Future<List<ChatMessage>> getMessages(String userId, String friendId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/messages/$userId/$friendId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ChatMessage.fromMap(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print("Get Messages Error: $e");
    }
    return [];
  }

  Future<ChatMessage?> sendMessage(
    String senderId,
    String receiverId,
    String text,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-message'), // Updated route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'text': text,
        }),
      );
      if (response.statusCode == 200) {
        return ChatMessage.fromMap(jsonDecode(response.body));
      }
    } catch (e) {
      if (kDebugMode) print("Send Message Error: $e");
    }
    return null;
  }
}
