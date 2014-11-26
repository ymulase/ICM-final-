import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus

import processing.serial.*;
Serial myPort;

float x, y, w;
float newy;
float newx;
float pos;

float r;

float opacity;

int num;


int black;
int white;
int save;
boolean savefile = false;

boolean firstContact = false;

void setup() {
  size(displayWidth, displayHeight);
  background(0);
  blendMode(EXCLUSION);

  MidiBus.list(); 
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.
  x = width/2;
  y = height/2;

  String portName = "/dev/tty.usbmodem1411";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  if (black>0) {
    background(0);
    blendMode(EXCLUSION);
  } else if (white>0) {
    background(255);
    blendMode(BLEND);
  }
}


void noteOn(Note note) {
  // Receive a noteOn
  //String Data = note.toString();

  println();
  println("Note On:");
  println("--------");
  println("Channel:"+note.channel());
  println("Pitch:"+note.pitch());
  println("Velocity:"+note.velocity());


  color c;
  String n = note.name();
  char thenote = n.charAt(0);

  println(thenote);

  c = color(255);
  if (thenote == 'C') {
    c=color (255, 0, 0);
  } else if (thenote=='D') {
    c = color(255, 128, 0);
  } else if (thenote=='E') {
    c = color(255, 255, 0);
  } else if (thenote=='F') {
    c = color(0, 255, 0);
  } else if (thenote=='G') {
    c = color(0, 128, 255);
  } else if (thenote=='A') {
    c = color(0, 0, 255);
  } else if (thenote=='B') {
    c = color(255, 0, 255);
  }


  newx = map(note.pitch(), 21, 108, 0, width);
  newy = map(note.velocity(), 0, 120, height, 0);
  w = map(note.velocity(), 0, 120, 0, 10);
  opacity = map(note.velocity(), 0, 120, 0, 255);
r = map(note.velocity(),0,120,0,15);
  noFill();
  stroke(c, opacity);
  strokeWeight(w);
  strokeCap(PROJECT);


  line(x, y, newx, newy);

  num = int(map(note.velocity(), 40,120,0,3));
  for(int i = 0; i<num;i++){
    if(num!=0){
    line(x, y, newx+random(-10,10),newy+random(-10,10));
    line(x+random(-10,10),y+random(-10,10),newx,newy);
    }
  }

  ellipse(newx, newy, r, r);
 noFill();
  int circles = int(map(note.velocity(), 0, 120, 0, 5));
  for (int i=0; i<circles; i++) {
    strokeWeight(1);
    ellipse(x+random(100), y+random(100), 1, 1);
    ellipse(x-random(100), y-random(100), 1, 1);
  }

  x = newx;
  y = newy;
}


void serialEvent(Serial myPort) {
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  // if you got any bytes other than the linefeed:
  if (myString != null) {

    myString = trim(myString);

    // if you haven't heard from the microncontroller yet, listen:
    if (firstContact == false) {
      if (myString.equals("hello")) {
        myPort.clear();          // clear the serial port buffer
        firstContact = true;     // you've had first contact from the microcontroller
        myPort.write('A');       // ask for more
      }
    }
    // if you have heard from the microcontroller, proceed:
    else {
      // split the string at the commas
      // and convert the sections into integers:
      int sensors[] = int(split(myString, ','));

      // print out the values you got:
      for (int sensorNum = 0; sensorNum < sensors.length; sensorNum++) {
        print("Sensor " + sensorNum + ": " + sensors[sensorNum] + "\t");
      }
      // add a linefeed after all the sensor values are printed:
      println();
      if (sensors.length > 1) {
        black = sensors[2];
        white = sensors[1];
        save = sensors[0];
      }
    }
    // when you've parsed the data you have, ask for more:
    myPort.write("A");
  }

  if (save>0) {
    savefile = true; 
    noLoop();
  } else {
    savefile = false; 
    loop();
  }
  if (savefile == true) {
    saveFrame("IMAGES/img-######.tif");
  }
}
