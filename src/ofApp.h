#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"
#include "ofxGui.h"
#include "ofxXmlSettings.h"

#define NUM_GRADIENTS 4
#define XML_SETTINGS_FILE "mySettings.xml"

// statemachine
static int STATE_DEBUG_SENSOR = 0;
static int STATE_DEBUG_DRAWING = 1;
static int STATE_DEBUG_COLOUR = 2;
static int STATE_BUBBLE = 3;

class SimpleButton : public ofRectangle {
	public :
	string label;
	bool active;
	void draw() {
		ofPushMatrix();
		ofTranslate(x, y);
		ofPushStyle();
		
		if (active == false) {
			ofSetColor(0);
			ofFill();
			ofRect(0, 0, width, height);
		}
		
		ofSetColor(128, 0, 128, 128);
		ofSetLineWidth(4);
		ofLine(width, 0, width, height);
		ofSetLineWidth(1);
		ofSetColor(255);
		ofDrawBitmapString(label, 10, height/2);
		ofPopStyle();
		ofPopMatrix();
	}
};

class ofApp : public ofxiOSApp {
	
public:
	void setup();
	void update();
	void draw();
	void exit();
	
	void touchDown(ofTouchEventArgs & touch);
	void touchMoved(ofTouchEventArgs & touch);
	void touchUp(ofTouchEventArgs & touch);
	void touchDoubleTap(ofTouchEventArgs & touch);
	void touchCancelled(ofTouchEventArgs & touch);
	
	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
	
	// custom methods
	void drawShape();
	void drawDebugData();
	void drawColourPicker();
	void resetSensorButtonPressed();
	void updateSensorButtonPressed();
	void colourPickerButtonPressed();
	
	// statemachine
	int displayMode = STATE_DEBUG_SENSOR;
	
	// access the device magnetometer
    ofxCoreMotion coreMotion;
	
	// strength recorded in sensor
	int magnitude;
	int minSensor, maxSensor, restSensor;
	int targetSize, currentSize;
	float easing;
	
	// settings
	ofxXmlSettings XML;
	
	ofParameter<int>	minRange;
	ofParameter<int>	maxRange;
	ofParameter<int>	minSize;
	ofParameter<int>	maxSize;
	ofParameter<bool>	bDoBlink;
	ofParameter<int>	blinkSlowSpeed;
	ofParameter<int>	blinkFastSpeed;
	ofParameter<bool>	bFill;
	
	// GUI
	SimpleButton sensorButton;
	SimpleButton drawingButton;
	
	ofxButton resetSensorButton;
	ofxButton updateSensorButton;
	ofxButton colourPickerButton;
	ofxToggle toggleShape;
	
	ofxPanel sensorGui;
	ofxPanel drawingGui;
	
	// gradient images to colourpick
	ofImage gradients[NUM_GRADIENTS];
	int activeGradient;
	bool bNoGradient;
	bool bBlinkOn;
	int blinkSpeed;
	unsigned long lastBlinkTime;
};