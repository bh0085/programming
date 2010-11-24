//A simple program to read the analog outout of an unamplified mic.
//Setup:
// Mic plugged into analog 0.
// Mic plugged into ground.

int micPin = 0;
int ledPin = 13;
int sensorValue;

void setup(){
  //declare ledPin output
  pinMode(ledPin,OUTPUT);
  Serial.begin(9600);
}

void loop(){
  sensorValue = analogRead(micPin);
  Serial.print(sensorValue); 
  Serial.println();
  delay(100);
}
