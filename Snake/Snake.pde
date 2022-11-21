ArrayList<Integer> snakeBodyX = new ArrayList<Integer>(); //arrayList to store the x-coordinate of the snake
ArrayList<Integer> snakeBodyY = new ArrayList<Integer>(); //arrayList to store the y-coordinate of the snake

int startScreenCounter; //counter for the screens in the starting sequence
int endScreenCounter; //counter for the screens in the ending sequence
int textCounter; //counter to determine how many initials have been typed
int initialsCounter; //counter to reset the initals
int gridSquares=20; //number of squares in each column and row that the snake and apples can appear in
int size; //size of the grid squares, apples, and each snake particle
int snakeX, snakeY; //updates x and y coordinates of the snake
int appleX, appleY; //x and y coordinates of the apple
int score, highScore; //score and high score of the player
int startTime, currentTime, endTime; //start time, current time, and end time for the death sequence
int gameSpeed=8; //speed of the game, which appears to change the speed of the snake
int speedIncrease=50; //value to determine when the game increases speed
int savedHighScore;

boolean noUp, noDown, noLeft, noRight; //prevents the snake from moving in certain directions
boolean displayControls; //boolean to display the controls screen
boolean startGame, endGame; //determines if the game has started and ended
boolean newHighScore; //determines if there is a new high score
boolean die; //determines if the snake has collided with the edge of the screen or with itself

PImage snakeBody; //image of the individual snake particle
PImage apple; //image of the apple
PImage controlsScreen; //image of the controls screen
PImage highScoreScreen; //image of the high score screen
PImage[] startScreen = new PImage[8]; //images of the start screen
PImage[] endScreen = new PImage[2]; //images of the end screen

PFont arcadeFont; //font file of the arcade style font

String initials=" ";

PrintWriter saveHighScore; //writer to save the high score
PrintWriter saveInitials; //writer to save the initials of the high scorer

void setup() {
  fullScreen(); //gets rid of the toolbar
  surface.setSize(600, 600); //changes the full screen window size

  readHighScoreFile();
  readInitialsFile();

  snakeBody=loadImage("snakeBody.png");
  apple=loadImage("apple.png");
  controlsScreen=loadImage("controlsScreen.png");
  highScoreScreen=loadImage("highScoreScreen.png");
  arcadeFont=createFont("arcadeFont.TTF", 24);

  for (int index=0; index<startScreen.length; index++) //index variable has an initial value of 0, must be less than the length of startScreen array, and increases by increments of 1
    startScreen[index]=loadImage(str(index)+"startScreen.png");

  for (int index=0; index<endScreen.length; index++) //index variable has an initial value of 0, must be less than the length of endScreen array, and increases by increments of 1
    endScreen[index]=loadImage(str(index)+"endScreen.png");

  size=width/gridSquares; //sets the size to be equal to the width of the run window divided by the number of squares in each row
  endTime=3000; //sets the death sequence to end after 3 seconds

  snakeBodyX.add(int(random(gridSquares))); //randomizes the starting x-coordinate of the snake
  snakeBodyY.add(int(random(gridSquares))); //randomizes the starting y-coordinate of the snake
  appleX=int(random(gridSquares)); //randomizes the starting x-coordinate of the apple
  appleY=int(random(gridSquares)); //randomizes the starting y-coordinate of the apple

  saveHighScore=createWriter("highScore.txt");
  saveInitials=createWriter("initials.txt");
}

void draw() {
  saveHighScore.println(highScore); //saves the high score to a text file
  saveInitials.println(initials); //saves the initials to a text file

  background(#0B3D04); //dark green background
  startPlay();
  highScorePlay();
  endPlay();
  increaseSpeed();
  deathTimer();
  updateInitials();
  if (startGame==true && die==false) { //if the game has started and the death sequence has not begun
    snake();
    snakeCollision();
    boundaries();
    apples();
    gameScore();
  }
}

void readHighScoreFile() { //reads the data from the high score text file
  BufferedReader scoreReader = createReader("highScore.txt");
  String readHighScore = null; //string to extract data from the high score text file
  try { //used with catch to handle exceptions such as errors
    while ((readHighScore=scoreReader.readLine()) !=null) { // while there is data being extracted from the high score text file
      String[] displayHighScore=split(readHighScore, TAB); //split the lines of the high score text file
      highScore=int(displayHighScore[displayHighScore.length-1]); //store the last line of the high score text file in the high score variable
      savedHighScore=int(displayHighScore[displayHighScore.length-1]); //store the last line of the high score text file in the saved high score variable
    }
    scoreReader.close(); //finishes reading the high score text file
  }
  catch(IOException e) { //handles exceptions such as errors while used with try
    e.printStackTrace(); //passes errors
  }
}

void readInitialsFile() { //reads the data from the initials file
  BufferedReader initialsReader = createReader("initials.txt");
  String readInitials = null; //string to extract data from the initials text file
  try { //used with catch to handle exceptions such as errors
    while ((readInitials=initialsReader.readLine()) !=null) { //while there is data being extracted from the initials text file
      String[] displayInitials=split(readInitials, TAB); //split the lines of the initials text file
      initials=(displayInitials[displayInitials.length-1]); //store the last line of the high score text file in the initials variable
    }
    initialsReader.close(); //finishes reading the high score text file
  }
  catch(IOException e) { //handles exceptions such as errors while used with try
    e.printStackTrace(); //passes errors
  }
}

void startPlay() { //displays the start screen
  if (startGame==false) //if the game has not started
    image(startScreen[frameCount%80/10], 0, 0); //display the start screen

  if (startScreenCounter==1) //if the screen counter is equal to 1
    displayControls=true; //display the controls screen

  if (displayControls) //if controls are to be displayed
    image(controlsScreen, 0, 0); //display the controls screen
}

void snake() { //displays the snake and allows it to move
  for (int index=0; index<snakeBodyX.size(); index++) //index variable has an initial value of 0, must be less than the length of snakeBodyX arrayList, and increases by increments of 1
    image(snakeBody, snakeBodyX.get(index)*size, snakeBodyY.get(index)*size); //displays the snake

  if (die==false) { //if the death sequence has not started
    if (key==CODED) { //detects special keys
      if (keyCode==UP && noUp==false) { //if the up arrow key was the last key pressed and the snake is not moving down
        snakeX=0; //the snake does not move horizontally
        snakeY=-1; //the snake moves up
        noDown=true; //the snake cannot move down
        noLeft=false; //the snake can move left
        noRight=false; //the snake can move right
      } else if (keyCode==LEFT &&noLeft==false) { //if the left arrow key was the last key pressed and the snake is not moving right
        snakeX=-1; //the snake moves left
        snakeY=0; //the snake does not move vertically
        noUp=false; //the snake cannot move up
        noDown=false; //the snake cannot move down
        noRight=true; //the snake cannot move right
      } else if (keyCode==DOWN && noDown==false) { //if the down arrow key was the last key pressed and the snake is not moving up
        snakeX=0; //the snake does not move horizontally
        snakeY=1; //the snake moves down
        noUp=true; //the snake cannot move up
        noLeft=false; //the snake can move left
        noRight=false; //the snake can move right
      } else if (keyCode==RIGHT && noRight==false) { //if the right arrow key was the last key pressed and the snake is not moving left
        snakeX=1; //the snake moves right
        snakeY=0; //the snake does not move vertically
        noUp=false; //the snake can move up
        noDown=false; //the snake can move down
        noLeft=true; //the snake cannot move left
      }
    }
  }
}

void snakeCollision() { //checks if the snake has collided with another snake particle
  for (int index=1; index<snakeBodyX.size(); index++) //index variable has an initial value of 1, must be less than the length of snakeBodyX arrayList, and increases by increments of 1
    if (snakeBodyX.get(0)==snakeBodyX.get(index) && snakeBodyY.get(0)==snakeBodyY.get(index)) //if the head of the snake collides with another snake particle
      die=true; //the death sequence begins
}

void apples() { //displays the apple and adds a snake particle to the snake if the two collide
  image(apple, appleX*size, appleY*size); //displays the apple
  if (frameCount%gameSpeed==0) { //every gameSpeed frames
    snakeBodyX.add(0, snakeBodyX.get(0)+snakeX); //creates a new snake particle in the direction of snakeX
    snakeBodyY.add(0, snakeBodyY.get(0)+snakeY); //creates a new snake particle in the direction of snakeY

    if (appleX==snakeBodyX.get(0) && appleY==snakeBodyY.get(0)) { //if the snake collides with the apple
      appleX=int(random(gridSquares)); //randomizes the x-coordinate of the apple
      appleY=int(random(gridSquares)); //randomizes the y-coordinate of the apple
      score=score+10; //increases the score by 10
    } else if (die==false) {
      snakeBodyX.remove(snakeBodyX.size()-1); //removes the last x-coordinate snake particle
      snakeBodyY.remove(snakeBodyY.size()-1); //removes the last y-coordinate snake particle
    }
  }
}

void boundaries() { //checks if the snake has collided with the edge of the run window and if an apple has appeared inside the snake
  for (int index=0; index<snakeBodyX.size(); index++) { //index variable has an initial value of 0, must be less than the length of snakeBodyX arrayList, and increases by increments of 1
    if (snakeBodyX.get(0)<0 || snakeBodyX.get(0)>19 || snakeBodyY.get(0)<0 || snakeBodyY.get(0)>19) //if the head of the snake goes outside of the rin window
      die=true; //start death sequence

    if (appleX==snakeBodyX.get(index) && appleY==snakeBodyY.get(index)) { //if the apple would appear inside the snake
      appleX=int(random(gridSquares)); //randomizes the x-coordinate of the apple
      appleY=int(random(gridSquares)); //randomizes the y-coordinate of the apple
    }
  }
}

void increaseSpeed() { //increases the speed of the game
  if (score==speedIncrease) { //if the score reaches the speedIncrease milestone
    speedIncrease+=50; //increase the speedIncrease milestone by 50 points
    gameSpeed-=0.1; //increase the game speed by .5 frames per second
  }
}

void gameScore() { //displays the score during the game
  fill(#147208); //lighter green text colour
  textFont(arcadeFont); //arcade style text font
  textAlign(CENTER); //aligns the text
  text("SCORE:", 75, 30); //displays "SCORE:" in the top right corner
  text(score, 170, 30); //displays the score next to "SCORE:"
}

void deathTimer() { //displays the death sequence
  if (die==false) //if the death sequence has not started
    startTime=millis(); //the timer to calculate the time between the start of the game and the start of the death sequence begins

  if (die) { //if the snake has collided with a boundary or itself
    snakeX=0; //the snake stops moving horizontally
    snakeY=0; //the snake stops moving vertically
    currentTime=millis(); //the timer to track the time of the death sequence begins
    if (currentTime-startTime>0 && currentTime-startTime<500 || currentTime-startTime>1000 && currentTime-startTime<1500||currentTime-startTime>2000&&currentTime-startTime<2500) { //every half a second
      snake(); //the snake is displayed
      apples(); //the apple is displayed
    }
  }

  if (currentTime-startTime>endTime) { //if 3 seconds have passed after the beginning of the death sequence
    if (score>savedHighScore) { //if the score is greater than the saved high score
      highScore=score; //the high score becomes the score
      newHighScore=true; //the new high score screen is displayed
    } else {
      endGame=true; //the game is over
    }
  }
}

void highScorePlay() { //displays the new high score screen
  if (newHighScore) { //if there is a new high score
    image(highScoreScreen, 0, 0); //display the high score

    if (frameCount%40!=0) { //every frame except the 40th frame
      textSize(50);
      textAlign(CENTER); //aligns the text
      text(highScore, width/2, 215); //displays the high score in the top middle of the screen
      text(initials, width/2, 435); //displays the initials of the high scorer in the bottom middle of the screen
    }
  }
}

void endPlay() { //displays the end screen
  if (endGame==true) { //if the game is over
    image(endScreen[frameCount%20/15], 0, 0); //display the game over screen

    textSize(25);
    text(score, 225, 421); //display the score of the last game
    text(highScore, 345, 486); //display the high score
    text(initials, 430, 486); //displays the initials of the high scorer
  }
}

void updateInitials() { //clears the saved initials when there is a new high score
  if (newHighScore && initialsCounter==0) //if there is a new high score and the initials counter is 0
    initialsCounter++; //increase the initials counter to 1

  if (initialsCounter==1) { //if the initials counter is equal to 1
    initials=""; //reset the initials
    initialsCounter++; //increase the initials counter to stop the initials from continually resetting
  }
}

void restart() { //restarts the game
  startGame=false; //the game has not started
  die=false; //the death sequence has not begun
  endGame=false; //the game is not over

  if (newHighScore)
    newHighScore=false; //there is no longer a new high score

  snakeBodyX.clear(); //all but 1 x-coordinate for the snake are removed
  snakeBodyY.clear();  //all but 1 x-coordinate for the snake are removed
  snakeBodyX.add(int(random(gridSquares))); //randomizes the x-coordinate of the snake
  snakeBodyY.add(int(random(gridSquares))); //randomizes the y-coordinate of the snake

  snakeX=0; //the snake is not moving horizontally
  snakeY=0; //the snake is not moving vertically
  noUp=false; //the snake can move up
  noDown=false; //the snake can move down
  noLeft=false; //the snake can move left
  noRight=false; //the snake can move right

  startScreenCounter=0; //the start screen counter is reset to 0
  endScreenCounter=0; //the end screen counter is reset to 0
  textCounter=0; //the text counter is reset to 0
  initialsCounter=0; //the initials counter is reset to 0
  score=0; //the score is reset to 0
  gameSpeed=8; //the game speed is reset
  speedIncrease=50; //the speed increase milestone is reset
  savedHighScore=highScore; //the high score becomes the saved high score
}

void keyPressed() {
  if (newHighScore && textCounter<3) { //if there is a new high score and the text counter is less than 3
    initials=initials+key; //store the keys pressed
    textCounter++; //increase the text counter
  }

  if (key==ENTER) { //if Enter is pressed
    if (startGame==false && startScreenCounter<2) { //if the game has not started and the screen counter is less than 2
      startScreenCounter++; //the screen counter increases by 1

      if (startScreenCounter==2) { //if the screen counter is equal to 2
        startGame=true; //the game starts
        displayControls=false; //the controls are not displayed
      }
    }

    if (newHighScore && endScreenCounter<2) //if there is a new high score and the text counter is less than 2
      endScreenCounter++; //increase the end screen counter

    if (endScreenCounter==1) //if the end screen counter is equal to 1
      endGame=true; //the game has ended

    if (endGame && newHighScore==false || endScreenCounter==2) { //if the game has ended and there is not a new high score or the end screen counter is equal to 2
      saveHighScore.flush(); //ensures the high score is saved to the text file before the program is closed
      saveHighScore.close(); //finishes the high score text file
      saveInitials.flush(); //ensures the initials are saved to the text file before the program is closed
      saveInitials.close(); //finishes the initials text file
      exit(); //exits the program
    }
  }

  if (endGame && key=='r') { //if the game has ended and 'r' is pressed
    restart(); //restarts the game
  }

  if (key==ESC) //if ESC is pressed
    key=0; //the program does not close
}
