class UserCard {
  static const String componentId = 'silhouette-usercard-542940';

  final String username;
  final String email;
  final int age;
  final bool isPremium;

  late final String displayInfo;
  late final String statusText;

  UserCard({required this.username, required this.email, this.age = 18, this.isPremium = false}) {
    displayInfo = '$username ($email)';
    statusText = isPremium ? 'Premium User' : 'Free User';
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-usercard-542940 user-card\"><h2>");
    buffer.write(username);
    buffer.write("</h2><p>Email: ");
    buffer.write(email);
    buffer.write("</p><p>Age: ");
    buffer.write(age);
    buffer.write("</p><p>Status: ");
    buffer.write(statusText);
    buffer.write("</p>");
    if (isPremium) {
      buffer.write("<div class=\"premium-badge\">⭐ Premium</div>");
    }
    buffer.write("</div>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-usercard-542940 .user-card { \n    padding: 20px;\n    border: 1px solid #ddd;\n    border-radius: 8px;\n  }.silhouette-usercard-542940 .premium-badge { \n    background: gold;\n    padding: 5px 10px;\n    border-radius: 4px;\n    display: inline-block;\n  }");
  }
}

