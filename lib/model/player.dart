class Player {
  final String uid;
  final String? emailAddress;
  final List<String> soloIds; // references to Solo docs
  final List<String> multiplayerIds; // references to Multiplayer docs

  Player({
    required this.uid,
    this.emailAddress,
    this.soloIds = const [],
    this.multiplayerIds = const [],
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'emailAddress': emailAddress,
    'soloIds': soloIds,
    'multiplayerIds': multiplayerIds,
  };

  factory Player.fromMap(Map<String, dynamic> map) => Player(
    uid: map['uid'],
    emailAddress: map['emailAddress'],
    soloIds: List<String>.from(map['soloIds'] ?? []),
    multiplayerIds: List<String>.from(map['multiplayerIds'] ?? []),
  );
}
