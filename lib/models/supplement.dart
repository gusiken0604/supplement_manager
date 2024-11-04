class Supplement {
  String name;
  String category;
  String form;
  int dose;
  int dailyIntake;

  Supplement({
    required this.name,
    required this.category,
    required this.form,
    required this.dose,
    required this.dailyIntake,
  });

   // Mapに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'form': form,
      'dose': dose,
      'dailyIntake': dailyIntake,
    };
  }

  // MapからSupplementオブジェクトを作成するメソッド
  factory Supplement.fromMap(Map<String, dynamic> map) {
    return Supplement(
      name: map['name'],
      category: map['category'],
      form: map['form'],
      dose: map['dose'],
      dailyIntake: map['dailyIntake'],
    );
  }
}
