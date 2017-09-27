static final int NUMBER_OF_BOMBS = 20;

static final int SCREEN_WIDTH = 700, SCREEN_HEIGHT = 700;
static final int OVERLAY_HEIGHT = SCREEN_WIDTH / 8;

static final int GRID_WIDTH = 15, GRID_HEIGHT = 10;
static final int GRID_MARGIN = 50;
static final int GRID_X = GRID_MARGIN, GRID_Y = GRID_MARGIN + OVERLAY_HEIGHT;

static final int SQUARE_SIZE = (int)((SCREEN_WIDTH - 2*GRID_X) / GRID_WIDTH);
static final int SQUARE_MARGIN = SQUARE_SIZE / 4;
static final int NUMBER_SIZE = SQUARE_SIZE / 2;

PImage flag, bomb;
Button resetButton;
Square[][] grid;

boolean gameOver = false;
boolean gameWin = false;
boolean firstClick = true;

String titleText;  //Text at top of screen
int flagsPlaced = 0;
int startTime, time;  //Game time in milliseconds

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {  
  flag = loadImage("flag.png");
  flag.resize(SQUARE_SIZE - SQUARE_MARGIN, SQUARE_SIZE - SQUARE_MARGIN);
  bomb = loadImage("bomb.png");
  bomb.resize(SQUARE_SIZE - SQUARE_MARGIN, SQUARE_SIZE - SQUARE_MARGIN);

  resetButton = new Button(20, 20, 100, 40, "Reset");
  grid = new Square[GRID_WIDTH][GRID_HEIGHT];

  //Create blank squares
  for (int i = 0; i < GRID_WIDTH; i++) {
    for (int j = 0; j < GRID_HEIGHT; j++) {
      grid[i][j] = new Square(GRID_X + (i * SQUARE_SIZE), GRID_Y + (j * SQUARE_SIZE), SQUARE_SIZE, SQUARE_SIZE);
    }
  }

  initialise();

  textAlign(CENTER);
}

void initialise() {
  //Add bombs
  int bombsToPlace = NUMBER_OF_BOMBS;
  while (bombsToPlace > 0) {
    int x = (int)random(GRID_WIDTH);
    int y = (int)random(GRID_HEIGHT);

    if (grid[x][y].isBomb == false) {
      grid[x][y].isBomb = true;
      bombsToPlace--;
    }
  }

  //Set neighbours
  for (int i = 0; i < GRID_WIDTH; i++) {
    for (int j = 0; j < GRID_HEIGHT; j++) {
      grid[i][j].neighbours = getNeighbours(i, j);
    }
  }
}

void draw() {
  background(200);

  //Draw overlay
  fill(#A468D6);
  rect(0, 0, width, OVERLAY_HEIGHT);

  //Draw title text on overlay
  if (gameWin) {
    fill(0, 255, 0);
    titleText = "You Win!";
  }
  else if (gameOver) {
    fill(255, 0, 0);
    titleText = "You Lose";
  }
  else {  //if playing game
    fill(0);
    titleText = "Bombs remaining = " + (NUMBER_OF_BOMBS - flagsPlaced);
  }
  textSize(20);
  text(titleText, width/2, 2*(OVERLAY_HEIGHT/3));
  
  //Draw timer
  if (!firstClick && !gameOver && !gameWin) {
    time = millis()-startTime;
  }
  text("Time: " + time/1000 + "s", width-100, 2*(OVERLAY_HEIGHT/3));
  
  //Draw reset button
  resetButton.display();

  //Draw all squares
  for (int i = 0; i < GRID_WIDTH; i++) {
    for (int j = 0; j < GRID_HEIGHT; j++) {
      grid[i][j].display();
    }
  }
  
  //Check if game has been won
  if (allBlanksRevealed()) {
    gameWin = true;
  }

  if (resetButton.isPressed()) {
    reset();
  }
}

void reset() {
  for (int i = 0; i < GRID_WIDTH; i++) {
    for (int j = 0; j < GRID_HEIGHT; j++) {
      grid[i][j].isRevealed = false;
      grid[i][j].isFlagged = false;
      grid[i][j].isBomb = false;
    }
  }

  initialise();
  firstClick = true;
  gameOver = false;
  gameWin = false;
  flagsPlaced = 0;
  time = 0;
}

//Have all non-bombs been revealed?
boolean allBlanksRevealed() {
  int revealed = 0;

  for (int i = 0; i < GRID_WIDTH; i++) {
    for (int j = 0; j < GRID_HEIGHT; j++) {
      if (grid[i][j].isRevealed && !grid[i][j].isBomb) {
        revealed++;
      }
    }
  }

  return (revealed == (GRID_WIDTH * GRID_HEIGHT) - NUMBER_OF_BOMBS);
}

//Return the number of bombs adjacent to grid[i][j]
int getNeighbours(int x, int y) {
  int neighbours = 0;

  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j <= y+1; j++) {
      if (onBoard(i, j) && grid[i][j].isBomb && !(i == x && j == y)) {
        neighbours++;
      }
    }
  }

  return neighbours;
}

boolean onBoard(int x, int y) {
  return !(x < 0 || x >= GRID_WIDTH || y < 0 || y >= GRID_HEIGHT);
}

void mousePressed() {
  if (!gameOver && !gameWin) {
    for (int i = 0; i < GRID_WIDTH; i++) {
      for (int j = 0; j < GRID_HEIGHT; j++) {
        if (grid[i][j].isTouching(mouseX, mouseY)) {
          Square square = grid[i][j];  //square = clicked square
  
          if (firstClick) {
            firstClick = false;
            startTime = millis();
          }
  
          //Left click is to reveal
          if (mouseButton == LEFT) {
            if (!square.isFlagged) {
              square.isRevealed = true;
  
              if (square.isBomb) {
                gameOver();
              }
              else if (square.neighbours == 0) {
                revealNeighbours(i, j);
              }
            }
          }
          //Right click is to flag
          else if (mouseButton == RIGHT) {
            if (!square.isRevealed) {
              if (square.isFlagged) {  //remove flag
                square.isFlagged = false;
                flagsPlaced--;
              }
              else {  //place flag
                square.isFlagged = true;
                flagsPlaced++;
              }
            }
          }
          //Middle click to clear 3x3 if flags are correct
          else if (mouseButton == CENTER) {
            if (flagsAround(i, j) == square.neighbours) {
              revealNeighbours(i, j);
            }
          }
        }
      }
    }
  }
}

void gameOver() {
  gameOver = true;
  revealMines();
}

//Reveal all unflagged mines
void revealMines() {
  for (int i = 0; i < GRID_WIDTH; i++) {
    for (int j = 0; j < GRID_HEIGHT; j++) {
      if (grid[i][j].isBomb && !grid[i][j].isFlagged) {
        grid[i][j].isRevealed = true;
      }
    }
  }
}

void revealNeighbours(int x, int y) {
  //Reveal all neighbours in 3x3
  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j <= y+1; j++) {
      if (onBoard(i, j) && !grid[i][j].isFlagged) {
        if (grid[i][j].isBomb) {
          gameOver();
          return;
        }
        else {
          grid[i][j].isRevealed = true;
        }
      }
    }
  }
  //Recursively reveal all neighbours with no bombs in 3x3
  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j <= y+1; j++) {
      if (onBoard(i, j) && !grid[i][j].isFlagged) {
        if (grid[i][j].neighbours == 0 && !allNeighboursRevealed(i, j)) {
          revealNeighbours(i, j);
        }
      }
    }
  }
}

//Have all of grid[i][j]'s neighbours been revealed?
boolean allNeighboursRevealed(int x, int y) {
  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j <= y+1; j++) {
      if (onBoard(i, j) && !grid[i][j].isRevealed) {
        return false;
      }
    }
  }
  return true;
}

//Returns the number of flags placed in the 3x3 surrounding grid[i][j]
int flagsAround(int x, int y) {
  int flags = 0;

  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j <= y+1; j++) {
      if (onBoard(i, j) && grid[i][j].isFlagged) {
        flags++;
      }
    }
  }
  return flags;
}