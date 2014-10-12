#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"
#include "ofxGui.h"
#include "ofxXmlSettings.h"

#define EASING 0.5 //[0.001, 0.999]
#define NUM_GRADIENTS 4
#define XML_SETTINGS_FILE "mySettings.xml"

#define DRAWING_MODE_A 1
#define DRAWING_MODE_B 2
#define DRAWING_MODE_C 3

#define CONTROL_TAB_DRAWING 1
#define CONTROL_TAB_SENSOR 2

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
	
private:
	
	// sensor values
	ofxCoreMotion coreMotion;
	int magnitude;
	int minSensor;
	int maxSensor;
	int restSensor;
	
	// Interface values
	int drawingMode;
	bool followTouch;
	ofPoint lastTouchPoint;
	
	int targetSize;
	int currentSize;

	
	// Settings
	ofxXmlSettings XML;
	ofParameter<int>	lineWeight;
	ofParameter<int>	minRange;
	ofParameter<int>	maxRange;
	ofParameter<int>	minSize;
	ofParameter<int>	maxSize;
	ofParameter<bool>	bDoBlink;
	ofParameter<int>	blinkSlowSpeed;
	ofParameter<int>	blinkFastSpeed;
	
	// custom methods
	void drawModeA();
	void drawModeB();
	void drawModeC();	
	void drawDebugData();
	void drawColourPicker();
	void resetSensorButtonPressed();
	void updateSensorButtonPressed();
	void colourPickerButtonPressed();
	void onSwipe(int direction, ofTouchEventArgs & touch);
		
	// GUI
	int controlTab;
	
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
	bool bBlinkOn;
	int blinkSpeed;
	unsigned long lastBlinkTime;
	
};