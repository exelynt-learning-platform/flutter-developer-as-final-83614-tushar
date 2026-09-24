import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
  });

  static const empty = AppUser(uid: '', email: '');

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
