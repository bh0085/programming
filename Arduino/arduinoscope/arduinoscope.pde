/*
this goes on your arduino
for use with Processing example SimpleSerialArduinoscope

*/

// prefactor stuff...
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif


// holds temp vals
int val;

void setup() {
  // set 2-12 digital pins to read mode
  for (int i=2;i<14;i++){
    pinMode(i, INPUT);
  }
  
  Serial.begin(115200); 
  cbi(ADCSRA,ADPS2) ;
  sbi(ADCSRA,ADPS1) ;
  sbi(ADCSRA,ADPS0) ; 
  pinMode(3,OUTPUT);
  pinMode(11,OUTPUT);
  TCCR2A = _BV(COM2A0) | _BV(COM2B1) | _BV(WGM21) | _BV(WGM20);
  TCCR2B = _BV(WGM22) | _BV(CS22);
  // A CS of 0x07 gives the longest possible prescaling.
  // f = 16mhz/ 1024/ OCR2A on timer 2
  TCCR2B = TCCR2B & 0b11111000 | 0x05;
  OCR2A = 255;
  OCR2B = 127;

}

void loop() {  
  // read nRead Analog ports split by " "
  int nRead = 1;
  for (int i=0;i<6;i++){
    if (i < nRead ){
        Serial.print(analogRead(i));
    } else {
       Serial.print(0); 
    }
    Serial.print(" ");
  }
  
  // read nRead Digital ports, split by " "
  int nDigitalRead = 0;
  for (int i=2;i<14;i++){
    if (i -2 < nDigitalRead){
      Serial.print(digitalRead(i));
    } else{
      Serial.print(0); 
    }
    Serial.print(" ");
  }
  
  // frame is marked by LF
  Serial.println();
}
