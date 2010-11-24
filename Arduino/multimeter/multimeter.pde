/*
 * Code for a specialized multimeter designed to
 * calculate capacitance and inductance.
 */

//import math    

// prefactor stuff...
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif


int a0 = 3;
int a1 = 4;
float r1 = 3300;
//use serial printing or send data to processing
int doProc = 1;
//number of points to send to processing
int nProc = 200;
//a window to plot in processing, in microseconds
int procWindow = 5000;
//allow the writing of a switching signal.
//if nSwitch <= 0, no switching occurs.
int nSwitch = 10;


//cooldown time to allow elements to reset
int cooldown = 500;
void setup(){
  pinMode(a0,OUTPUT);
  Serial.begin(57600); 
  
  cbi(ADCSRA,ADPS2) ;
  sbi(ADCSRA,ADPS1) ;
  sbi(ADCSRA,ADPS0) ; 
  
}

void loop(){

  //Send data to processing
  if (doProc == 1){

    int inc = procWindow/nProc;
    int analogs[nProc];

    digitalWrite(a0, HIGH);

    int switchTimer = nSwitch;
    int vTog = 0;

    for ( int i = 0 ; i < nProc ; i++){
      analogs[i] = analogRead(a1);
      switchTimer--;
      if (switchTimer == 0){
	switchTimer += nSwitch;
	if (vTog == 1){
	  digitalWrite(a0,HIGH);
	} else {
	  digitalWrite(a0,LOW);
	}
	vTog = 1-vTog;
      }
      //delayMicroseconds(inc);
    }
    digitalWrite(a0,LOW);

    
    //Serial.println(analogs[0]);
    //Serial.println(analogs[2]);
    //Serial.println(analogs[3]);    
    //Serial.println();
    analogArrayPrintProcBytes(analogs,nProc);
    delay(cooldown);
   
  } else {
    //If we are not sending data to processing then compute
    //induction, capacitance, etc based on the value of type.
    //
    //Print everything with notation to the serial.
 
    Serial.print("Make sure that lead v0 is");
    Serial.println("connected to D3 and v1 to A4");
    Serial.print("Resistance: ");
    Serial.println(r1);

    
    //Set type to what you like.
    //0: Capacitance
    //1: Inductance
    int type = 1;

    //CAPACITANCE
    if (type == 0){
      float v0 = 5.0;
      int a0Val = voltageToAnalog(v0);
      int tauAnalog =( voltageToAnalog( v0 *0.632 ));
  
      digitalWrite(a0, HIGH);
      //note that analogReadSpeed is ~100 microseconds with no
      //prefactor set.
      int m0 = millis();
      int startingAnalog = analogRead(a1);

      while ( analogRead(a1) < tauAnalog ){
	delayMicroseconds(50);
      }
      int m1 = millis();
      float tau = m1 - m0;
      float c1 =  tau / r1;
  
      Serial.print("Starting actual analog: ");
      Serial.println(startingAnalog);
      Serial.print("Tau: ");
      Serial.println(tau);
      Serial.println();
  
      Serial.print("Capacitance: ");
      Serial.print(c1);
      Serial.println();

  
    } 
    //type 1: inductance
    if (type == 1){
      float v0 = 5.0;
      int a0Val = voltageToAnalog(v0);
      int tauAnalog =( voltageToAnalog( v0 *(1 - 0.632) ));
  
      digitalWrite(a0, HIGH);
      //note that analogReadSpeed is ~100 microseconds with no
      //prefactor set.
      int m0 = millis();
      int startingAnalog = analogRead(a1);
  
      //Serial.print("Starting analog: ");
      //Serial.println(a0Val);

  
      while ( analogRead(a1) > tauAnalog ){
	delayMicroseconds(50);
      }
  
      int m1 = millis();
      int finish_analog = analogRead(a1);
      float tau = m1 - m0;
      float l1 =  r1  * tau;
  
      Serial.print("Starting actual analog: ");
      Serial.println(startingAnalog);  
      Serial.print("Finishing actual analog: ");
      Serial.println(finish_analog);
      Serial.print("Tau: ");
      Serial.println(tau);
      Serial.println();
      Serial.print("Inductance: ");
      Serial.print(l1);
      Serial.println();  
    }
 
    if (doProc == 1){
      Serial.println();
    }  
    digitalWrite(a0,LOW);
    delay(2000); 
  }

}
float analogArrayPrintProcBytes(int arr[], int length){
  for (int i = 0 ; i < length; i++){
    int b = ((float)arr[i] )*256.0/ 1024.0 ;
    Serial.print(b,BYTE); 
  }
}

float analogToVoltage(int analog){
  float val =  analog;
  val = val /1024;
  val = val*5;
  return val;
}
int voltageToAnalog(float voltage){
  float val =  voltage;
  val = val /5;
  int out = val * 1023;
  return out;
}

