import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_logger.dart';

/// Generic Supabase Broadcast channel wrapper.
/// Used for customer display and pairing real-time communication.
class BroadcastChannel {
  BroadcastChannel(this._supabase);

  final SupabaseClient _supabase;

  RealtimeChannel? _channel;
  String? _channelName;
  bool _subscribed = false;
  Timer? _reconnectTimer;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;
  bool get isJoined => _channel != null;
  bool get isSubscribed => _subscribed;

  /// Join a broadcast channel. Returns a Future that completes when the
  /// subscription reaches SUBSCRIBED state. Idempotent — if already joined
  /// to the same channel, returns immediately.
  Future<void> join(String channelName) {
    if (_channelName == channelName && _channel != null) {
      return Future.value();
    }
    leave();

    _channelName = channelName;
    _subscribed = false;
    final completer = Completer<void>();

    _channel = _supabase
        .channel(channelName)
        .onBroadcast(
          event: 'payload',
          callback: (payload) {
            if (!_controller.isClosed) {
              _controller.add(payload);
            }
          },
        )
        .subscribe((status, [error]) {
      AppLogger.info(
        'BroadcastChannel($channelName): status=$status',
        tag: 'BROADCAST',
      );
      if (status == RealtimeSubscribeStatus.subscribed &&
          !completer.isCompleted) {
        _subscribed = true;
        completer.complete();
      }
      if (error != null) {
        AppLogger.error(
          'BroadcastChannel($channelName): error',
          tag: 'BROADCAST',
          error: error,
        );
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      }
      if ((status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) &&
          completer.isCompleted) {
        _scheduleReconnect();
      }
    });

    return completer.future;
  }

  /// Send a payload to the current channel.
  Future<void> send(Map<String, dynamic> payload) async {
    if (_channel == null || !_subscribed) {
      AppLogger.warn(
        'BroadcastChannel($_channelName): send skipped (subscribed=$_subscribed)',
        tag: 'BROADCAST',
      );
      return;
    }
    try {
      await _channel!.sendBroadcastMessage(
        event: 'payload',
        payload: payload,
      );
    } catch (e, s) {
      AppLogger.error(
        'BroadcastChannel($_channelName): failed to send',
        tag: 'BROADCAST',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Leave the current channel.
  void leave() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
      _channelName = null;
      _subscribed = false;
    }
  }

  /// Dispose — leave channel and close stream controller.
  void dispose() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    leave();
    _controller.close();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    final name = _channelName;
    if (name == null) return;
    AppLogger.info('BroadcastChannel($name): scheduling reconnect in 10s', tag: 'BROADCAST');
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      if (_channelName != name) return;
      AppLogger.info('BroadcastChannel($name): reconnecting...', tag: 'BROADCAST');
      leave();
      join(name);
    });
  }
}
