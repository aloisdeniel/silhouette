class UserCard {
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
    buffer.write("<div");
    buffer.write(" class=\"user-card\"");
    buffer.write(">");
    buffer.write("<h2");
    buffer.write(">");
    buffer.write(username);
    buffer.write("</h2>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Email: ");
    buffer.write(email);
    buffer.write("</p>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Age: ");
    buffer.write(age);
    buffer.write("</p>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Status: ");
    buffer.write(statusText);
    buffer.write("</p>");
    if (isPremium) {
      buffer.write("<div");
      buffer.write(" class=\"premium-badge\"");
      buffer.write(">");
      buffer.write("⭐ Premium");
      buffer.write("</div>");
    }
    buffer.write("</div>");
  }
}

