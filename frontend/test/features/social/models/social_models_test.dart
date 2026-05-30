// Tests for all social feature DTO models:
//   PostWithCommentCountDto, CommentDto, ConversationPreviewDto,
//   FriendDto, FriendRequestDto, MessageDto, SearchUserDto.
// All are pure-Dart data classes with fromJson factories.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/social/presentation/model/PostWithCommentCountDto.dart';
import 'package:care_connect_app/features/social/presentation/model/comment_dto.dart';
import 'package:care_connect_app/features/social/presentation/model/conversation_preview_dto.dart';
import 'package:care_connect_app/features/social/presentation/model/friend_dto.dart';
import 'package:care_connect_app/features/social/presentation/model/friend_request_dto.dart';
import 'package:care_connect_app/features/social/presentation/model/message_dto.dart';
import 'package:care_connect_app/features/social/presentation/model/search_user_dto.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────
  // PostWithCommentCountDto
  // ─────────────────────────────────────────────────────────────────────

  group('PostWithCommentCountDto.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies the happy-path where every JSON key is present.
      final post = PostWithCommentCountDto.fromJson({
        'id': 1,
        'userId': 10,
        'content': 'Hello world!',
        'imageUrl': 'https://example.com/img.png',
        'createdAt': '2025-06-15T12:00:00.000',
        'commentCount': 5,
        'username': 'alice',
      });

      expect(post.id, 1);
      expect(post.userId, 10);
      expect(post.content, 'Hello world!');
      expect(post.imageUrl, 'https://example.com/img.png');
      expect(post.createdAt, DateTime.parse('2025-06-15T12:00:00.000'));
      expect(post.commentCount, 5);
      expect(post.username, 'alice');
    });

    test('imageUrl is null when absent from JSON', () {
      // Verifies that a missing imageUrl key produces null.
      final post = PostWithCommentCountDto.fromJson({
        'id': 2,
        'userId': 1,
        'content': 'No image',
        'createdAt': '2025-01-01T00:00:00.000',
        'commentCount': 0,
        'username': 'bob',
      });
      expect(post.imageUrl, isNull);
    });

    test('username defaults to Unknown User when absent', () {
      // Verifies the username ?? 'Unknown User' fallback.
      final post = PostWithCommentCountDto.fromJson({
        'id': 3,
        'userId': 1,
        'content': 'Anon post',
        'createdAt': '2025-01-01T00:00:00.000',
        'commentCount': 0,
      });
      expect(post.username, 'Unknown User');
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // CommentDto
  // ─────────────────────────────────────────────────────────────────────

  group('CommentDto.fromJson', () {
    test('parses all fields correctly', () {
      // Verifies that all JSON keys map to the correct DTO fields.
      final comment = CommentDto.fromJson({
        'id': 100,
        'userId': 5,
        'postId': 20,
        'content': 'Great post!',
        'username': 'charlie',
        'createdAt': '2025-03-10T09:00:00.000',
      });

      expect(comment.id, 100);
      expect(comment.userId, 5);
      expect(comment.postId, 20);
      expect(comment.content, 'Great post!');
      expect(comment.username, 'charlie');
      expect(comment.timestamp, DateTime.parse('2025-03-10T09:00:00.000'));
    });

    test('username defaults to Unknown User when absent', () {
      // Verifies the username ?? 'Unknown User' fallback.
      final comment = CommentDto.fromJson({
        'id': 1,
        'userId': 1,
        'postId': 1,
        'content': 'Hi',
        'createdAt': '2025-01-01T00:00:00.000',
      });
      expect(comment.username, 'Unknown User');
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // ConversationPreviewDto
  // ─────────────────────────────────────────────────────────────────────

  group('ConversationPreviewDto.fromJson', () {
    test('parses all fields correctly', () {
      // Verifies that all JSON keys map to the correct DTO fields.
      final conv = ConversationPreviewDto.fromJson({
        'peerId': 7,
        'peerName': 'Diana',
        'content': 'Hey there!',
        'timestamp': '2025-04-20T15:30:00.000',
      });

      expect(conv.peerId, 7);
      expect(conv.peerName, 'Diana');
      expect(conv.content, 'Hey there!');
      expect(conv.timestamp, DateTime.parse('2025-04-20T15:30:00.000'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // FriendDto
  // ─────────────────────────────────────────────────────────────────────

  group('FriendDto.fromJson', () {
    test('parses all fields correctly', () {
      // Verifies that id, name, and email are mapped from JSON.
      final friend = FriendDto.fromJson({
        'id': 42,
        'name': 'Eve Johnson',
        'email': 'eve@example.com',
      });

      expect(friend.id, 42);
      expect(friend.name, 'Eve Johnson');
      expect(friend.email, 'eve@example.com');
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // FriendRequestDto
  // ─────────────────────────────────────────────────────────────────────

  group('FriendRequestDto.fromJson', () {
    test('parses all fields correctly', () {
      // Verifies that id, fromUserId, toUserId, and fromUsername are mapped.
      final req = FriendRequestDto.fromJson({
        'id': 55,
        'fromUserId': 3,
        'toUserId': 8,
        'from_username': 'frank',
      });

      expect(req.id, 55);
      expect(req.fromUserId, 3);
      expect(req.toUserId, 8);
      expect(req.fromUsername, 'frank');
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // MessageDto
  // ─────────────────────────────────────────────────────────────────────

  group('MessageDto.fromJson', () {
    test('parses all fields correctly', () {
      // Verifies that id, senderId, receiverId, content, and timestamp are mapped.
      final msg = MessageDto.fromJson({
        'id': 200,
        'senderId': 3,
        'receiverId': 9,
        'content': 'Hello!',
        'timestamp': '2025-05-01T10:00:00.000',
      });

      expect(msg.id, 200);
      expect(msg.senderId, 3);
      expect(msg.receiverId, 9);
      expect(msg.content, 'Hello!');
      expect(msg.timestamp, DateTime.parse('2025-05-01T10:00:00.000'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // SearchUserDto
  // ─────────────────────────────────────────────────────────────────────

  group('SearchUserDto.fromJson', () {
    test('parses all fields correctly', () {
      // Verifies that id, name, and email are mapped from JSON.
      final user = SearchUserDto.fromJson({
        'id': 99,
        'name': 'Grace Lee',
        'email': 'grace@example.com',
      });

      expect(user.id, 99);
      expect(user.name, 'Grace Lee');
      expect(user.email, 'grace@example.com');
    });
  });
}
