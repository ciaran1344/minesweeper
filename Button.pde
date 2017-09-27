class Button {
  float x, y, w, h;
  String text;

  Button(float x, float y, float w, float h, String text) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
  }

  void display() {
    if (isTouching(mouseX, mouseY)) {
      fill(200);
    }
    else {
      fill(150);
    }

    rect(x, y, w, h);

    fill(0);
    text(text, x + w/2, y + h/2);
  }

  boolean isTouching(float xPos, float yPos) {
    return (xPos > x && xPos < x + w && yPos > y && yPos < y + h);
  }

  boolean isPressed() {
    return mousePressed && isTouching(mouseX, mouseY);
  }
}