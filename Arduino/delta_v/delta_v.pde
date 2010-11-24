void setup(){
 Serial.begin(9600); 
}
void loop(){
 float v0 = analogToVoltage(analogRead(0)); 
 float v1 = analogToVoltage(analogRead(1));
 Serial.print("Delta V: ");
 Serial.print(v1 -v0);
 Serial.println();
 delay(50);
}


float analogToVoltage(int analog){
 float val =  analog;
 val = val /1024;
 val = val*5;
 return val;
}
