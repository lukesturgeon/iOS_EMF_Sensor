#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"
#include "ofxGui.h"
#include "ofxXmlSettings.h"
#include "ofxSimpleSlider.h"

#define EASING 0.5 //[0.001, 0.999]
#define NUM_GRADIENTS 4
#define XML_SETTINGS_FILE "mySettings.xml"

#define DRAWING_MODE_A 1
#define DRAWING_MODE_B 2
#define DRAWING_MODE_C 3

#define CONTROL_TAB_DRAWING 1
#define CONTROL_TAB_SENSOR 2

class SimpleButton : public ofRectangle {
	
private:
	string _label;

public:
	bool active;
	
	void setLabel(string l){
		_label = l;
	}
	
	void draw() {
		ofPushStyle();
		
		/*if (active == false) {
		 ofSetColor(255);
		 ofFill();
		 ofRect(0, 0, width, height);
		 }*/
		
		ofSetColor(255);
		ofRect(x, y, width, height);
		ofSetColor(0);
		ofRect(x+5, y+5, width-10, height-10);
		
		ofSetColor(255);
		ofDrawBitmapString(_label, x+10, y+height/2);
		ofPopStyle();
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
	int targetSize;
	int currentSize;
	
	// Interface values
	int drawingMode;
	bool followTouch;
	ofPoint lastTouchPoint;
	
	// Settings
	ofxXmlSettings XML;
	ofParameter<int>	lineWeight;
	ofParameter<int>	minRange;
	ofParameter<int>	maxRange;
	ofParameter<float>	minSize;
	ofParameter<float>	maxSize;
	ofParameter<bool>	bDoBlink;
	ofParameter<int>	blinkSlowSpeed;
	ofParameter<int>	blinkFastSpeed;
	
	// custom methods
	void drawModeA();
	void drawModeB();
	void drawModeC();	
	void drawDebugData();
	void drawColourPicker();
	void onSwipe(int direction, ofTouchEventArgs & touch);
	void saveSettings();
		
	// GUI
	int controlTab;
	
	SimpleButton setRestButton;
	SimpleButton useMinMaxButton;
	
	ofxSimpleSlider minSizeSlider;
	ofxSimpleSlider maxSizeSlider;
	
	ofxPanel sensorGui;
	ofxPanel drawingGui;
	
	// gradient images to colourpick
	ofImage gradients[NUM_GRADIENTS];
	int activeGradient;
	bool bBlinkOn;
	int blinkSpeed;
	unsigned long lastBlinkTime;
	
};