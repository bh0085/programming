/* 
 *Code for the electret microphone
 *Based on Knock and Calibrate from Arduino examples
 *by David Mellis,Tom Igoe and David Cuartielles
 *
 *
 *More info:
 *http://www.iua.upf.es/~jlozano/interfaces/microphone.html
 *Jose Lozano
 *
 *
 */


// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif


// these constants won't change:
const int ledPin = 13;      // led connected to digital pin 13
const int nElectret = 2;
int electrets[2];
int nRead = 100;

// these variables will change:
int sensorReading = 0;      // variable to store the value read from the sensor pin



void setup() {
  electrets[0] = 0;
  electrets[1] = 1;
  
  sbi(ADCSRA,ADPS2) ;
  cbi(ADCSRA,ADPS1) ;
  cbi(ADCSRA,ADPS0) ; 
  
  Serial.begin(57600);       // use the serial port
}

void loop() {
  int bs[nElectret * nRead];// = byte[nRead*nElectret];
  for (int k = 0 ; k < nRead; k++){
  for (int i = 0 ; i < nElectret ; i++){
    int pin = electrets[i];
    sensorReading = analogRead(pin);    



    //Serial.print(sensorReading); //Will send only positive and absolute values of waveform         
    float voltage = analogToVoltage(sensorReading);
    int b = voltage/5 * 256;
    //byte bb = byte(78);
    //byte bbb = 78;
    boolean print_volts = false;
  
    if (print_volts){
      Serial.print(b);
      //Serial.print(bbb);
      Serial.print(" Volts: ");
      Serial.print(voltage);
      Serial.println();
      delay(10);  // Better for Processing showing data
    } else {
      bs[k*nElectret+i] = b;
      //Serial.print(b); 
      //Serial.print(0); 
     
    } 
    }
  
  }
  for (int k = 0 ; k < nRead ; k++){
   for (int i = 0 ; i < nElectret; i++){
     Serial.print(bs[k*nElectret+i], BYTE); 
   } 
  }
  delay(10);
}


float analogArrayPrintProcBytes(int arr[], length){
  for (int i = 0 ; i < length; i++){
   b = arr[i] / 1024;
   Serial.print(b,BYTE); 
  }
}

float analogToVoltage(int analog){
 float val =  analog;
 val = val /1024;
 val = val*5;
 return val;
}
