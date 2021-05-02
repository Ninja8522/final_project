class Foods {
  int? idLocal;
  int? idServer;
  String? name;
  double? calories;

  Foods(
      {required this.idLocal,
      required this.idServer,
      required this.name,
      required this.calories});

  Foods.fromMapSQL(Map<String, dynamic> mapSQL) {
    idLocal = mapSQL["idLocal"];
    idServer = mapSQL["idServer"];
    name = mapSQL["name"];
    calories = mapSQL["calories"];
  }

  Map<String, dynamic> toMapSQL() {
    return {
      "idLocal": idLocal,
      "idServer": idServer,
      "name": name,
      "calories": calories
    };
  }
}
