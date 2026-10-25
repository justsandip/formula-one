/// Sample JSON shaped like the Jolpica (Ergast) standings responses.
/// Values are made up; only the structure matters.
Map<String, dynamic> driverJson({String code = 'NOR'}) => <String, dynamic>{
  'driverId': 'norris',
  'permanentNumber': '4',
  'code': code,
  'url': 'http://en.wikipedia.org/wiki/Lando_Norris',
  'givenName': 'Lando',
  'familyName': 'Norris',
  'dateOfBirth': '1999-11-13',
  'nationality': 'British',
};

Map<String, dynamic> constructorJson({
  String id = 'mclaren',
  String name = 'McLaren',
}) => <String, dynamic>{
  'constructorId': id,
  'url': 'http://en.wikipedia.org/wiki/McLaren',
  'name': name,
  'nationality': 'British',
};

Map<String, dynamic> driverStandingJson({
  String position = '1',
  String points = '408',
  String wins = '7',
  List<Map<String, dynamic>>? constructors,
}) => <String, dynamic>{
  'position': position,
  'positionText': position,
  'points': points,
  'wins': wins,
  'Driver': driverJson(),
  'Constructors': constructors ?? [constructorJson()],
};

Map<String, dynamic> constructorStandingJson({
  String position = '1',
  String points = '800',
  String wins = '14',
}) => <String, dynamic>{
  'position': position,
  'positionText': position,
  'points': points,
  'wins': wins,
  'Constructor': constructorJson(),
};

Map<String, dynamic> driverStandingsBody(List<Map<String, dynamic>> rows) =>
    <String, dynamic>{
      'MRData': <String, dynamic>{
        'StandingsTable': <String, dynamic>{
          'StandingsLists': rows.isEmpty
              ? <dynamic>[]
              : <dynamic>[
                  <String, dynamic>{'DriverStandings': rows},
                ],
        },
      },
    };

Map<String, dynamic> constructorStandingsBody(
  List<Map<String, dynamic>> rows,
) => <String, dynamic>{
  'MRData': <String, dynamic>{
    'StandingsTable': <String, dynamic>{
      'StandingsLists': rows.isEmpty
          ? <dynamic>[]
          : <dynamic>[
              <String, dynamic>{'ConstructorStandings': rows},
            ],
    },
  },
};
