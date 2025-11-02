sealed class ProfileFailure {
  const ProfileFailure();
}

class NotSignedIn extends ProfileFailure {
  const NotSignedIn();
}

class Network extends ProfileFailure {
  const Network();
}

class Unknown extends ProfileFailure {
  final String message;
  const Unknown(this.message);
}
