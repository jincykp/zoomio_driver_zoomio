import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore _firestore;

  NotificationBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(NotificationInitial()) {
    on<FetchNotificationStatus>(_onFetchNotificationStatus);
  }

  Future<void> _onFetchNotificationStatus(
    FetchNotificationStatus event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());

      final driverDoc = await _firestore
          .collection('driverProfiles')
          .doc(event.driverId)
          .get();

      if (!driverDoc.exists) {
        emit(NotificationError('Driver profile not found'));
        return;
      }

      final data = driverDoc.data() as Map<String, dynamic>;
      final isBlocked = data['isBlocked'] as bool;
      final lastBlockUpdate = (data['lastBlockUpdate'] as Timestamp?)?.toDate();

      emit(NotificationLoaded(
        isBlocked: isBlocked,
        lastBlockUpdate: lastBlockUpdate,
      ));
    } catch (e) {
      emit(NotificationError('Failed to fetch notification status: $e'));
    }
  }
}
