class Square {
  float x, y, w, h;
  boolean isFlagged = false;
  boolean isRevealed = false;
  boolean isBomb;
  int neighbours;

  Square(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    //Draw rectangle
    if (isRevealed) {
      if (isBomb) {
        fill(255, 0, 0);  //red if revealed and bomb
      }
      else {
        fill(255);  //white if revealed and not bomb
      }
    }
    else {
      if (isTouching(mouseX, mouseY)) {
        fill(170);  //grey if not revealed
      }
      else {
        fill(150);
      }
    }
    rect(x, y, w, h);

    if (isRevealed) {
      if (isBomb) {
        image(bomb, x + SQUARE_MARGIN/2, y + SQUARE_MARGIN/2);
      }
      else {  //show number of adjacent bombs
        switch (neighbours) {
        case 1: 
          fill(0, 0, 255);
          break;
        case 2:
          fill(0, 255, 0);
          break;
        case 3:
          fill (255, 0, 0);
          break;
        case 4:
          fill(#7913CE);
          break;
        case 5:
          fill(#F7BC3C);
          break;
        case 6:
          fill(#2AE0E8);
          break;
        case 7:
          fill(#F4F514);
          break;
        case 8:
          fill(#F514D0);
          break;
        default:
          fill(0);
        }

        if (neighbours > 0) {
          textSize(NUMBER_SIZE);
          text(neighbours, x + w/2, y + 3*h/4);
        }
      }
    }
    else if (isFlagged) {
      image(flag, x + SQUARE_MARGIN/2, y + SQUARE_MARGIN/2);
    }
  }

  boolean isTouching(float xPos, float yPos) {
    return (xPos > x && xPos < x + w && yPos > y && yPos < y + h);
  }
}