#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
	
    ofSetFrameRate(30);
    ofBackground(0);
	ofSetCircleResolution(64);
	ofxiOSDisableIdleTimer();
	
	ofLogNotice("width:" + ofToString(ofGetWidth()) + ", height:" + ofToString(ofGetHeight()));
	
	// load the gradient files
	for (int i = 0; i < NUM_GRADIENTS; i++) {
		gradients[i].loadImage("gradients/col" + ofToString(i) + ".png");
	}
	
	//------
	// attempt to load the settings
	ofLogNotice("loading mySettings.xml");
	if ( XML.loadFile(ofxiOSGetDocumentsDirectory() + XML_SETTINGS_FILE) ) {
		ofLogNotice("settings loaded from iOS documents");
	}
	else if ( XML.loadFile( XML_SETTINGS_FILE ) ) {
		ofLogNotice("settings loaded from data folder");
	}
	else {
		ofLogNotice("unable to load settings!");
	}
	//------
	
	ofxGuiSetDefaultWidth(300);
	ofxGuiSetDefaultHeight(30);
	ofxGuiSetTextPadding(6);
	
	resetSensorButton.addListener(this,&ofApp::resetSensorButtonPressed);
	updateSensorButton.addListener(this,&ofApp::updateSensorButtonPressed);
	colourPickerButton.addListener(this,&ofApp::colourPickerButtonPressed);
	
	float mSize = ofGetWidth()/2;
	
	sensorGui.setup("Sensor");
	sensorGui.setPosition(10,80);
	sensorGui.add(minRange.set("low", XML.getValue("SENSOR:RANGE:LOW", 0), -2000, 0));
	sensorGui.add(maxRange.set("high", XML.getValue("SENSOR:RANGE:HIGH", 1), 1, 2000));
	sensorGui.add(resetSensorButton.setup("set baseline"));
	sensorGui.add(updateSensorButton.setup("use min/max"));
	
	drawingGui.setup("Drawing");
	drawingGui.setPosition(10,80);
	drawingGui.add(minSize.set("minSize", XML.getValue("SHAPE:SIZE:MIN", 0), 0, mSize));
	drawingGui.add(maxSize.set("maxSize", XML.getValue("SHAPE:SIZE:MAX", mSize), 0, mSize));
	drawingGui.add(colourPickerButton.setup("set gradient"));
	drawingGui.add(bDoBlink.set("blink", false));
	drawingGui.add(blinkSlowSpeed.set("blinkSlow", XML.getValue("SHAPE:BLINK:MIN", 1000), 10, 1000));
	drawingGui.add(blinkFastSpeed.set("blinkFast", XML.getValue("SHAPE:BLINK:MAX", 10), 10, 1000));
	
	// setup starting values
	restSensor = XML.getValue("SENSOR:REST", 0);
	activeGradient = XML.getValue("GRADIENT:ACTIVE_INDEX", 0);
	bBlinkOn = false;
	blinkSlowSpeed.set(1000);
	blinkFastSpeed.set(50);
	sensorButton.active = true;
	lineWeight.set(10); // default line weight
	drawingMode = DRAWING_MODE_A;
	
	// setup sensor
    coreMotion.setupMagnetometer();
	
	int w = ofGetWidth()/2;
	
	sensorButton.set(0, 0, w, 60);
	sensorButton.label = "SENSOR";
	
	drawingButton.set(w, 0, w, 60);
	drawingButton.label = "DRAWING";
}

//--------------------------------------------------------------
void ofApp::update(){
	
    coreMotion.update();
	
	// magnetometer data parse
	ofVec3f m = coreMotion.getMagnetometerData();
	magnitude = m.length();
	
	// record the peak values
	if (magnitude-restSensor > maxSensor) {
		maxSensor = magnitude-restSensor;
	}
	else if (magnitude-restSensor < minSensor) {
		minSensor = magnitude-restSensor;
	}
	
	// convert the values in to usefulness
	int x = abs(magnitude - restSensor);
	targetSize = ofMap(x, 0, maxRange, minSize, maxSize, true);
	currentSize += (targetSize - currentSize)  * EASING;
	blinkSpeed = ofMap(x, 0, maxRange, blinkSlowSpeed, blinkFastSpeed, true);
	
	unsigned long now = ofGetElapsedTimeMillis();
	
	if(bDoBlink) {
		if (!bBlinkOn && now - lastBlinkTime > blinkSpeed) {
			bBlinkOn = true;
			lastBlinkTime = now;
		}
		
		if (bBlinkOn && now - lastBlinkTime > 100) {
			bBlinkOn = false;
			lastBlinkTime = now;
		}
	}
}

//--------------------------------------------------------------
void ofApp::draw(){
	
	/*if (!bDoBlink || (bDoBlink && bBlinkOn)) {
		drawShape();
	}
	
	// check and show any debug stuff
	if (displayMode == STATE_DEBUG_SENSOR) {
		
		
	}
	
	else if (displayMode == STATE_DEBUG_COLOUR) {
		drawColourPicker();
	}*/
	
	// decide what to draw
	switch (drawingMode) {
		case DRAWING_MODE_A:
			// grow a circle
			drawModeA();
			break;
			
		case DRAWING_MODE_B:
			// blink a circle
			drawModeB();
			break;
			
		case DRAWING_MODE_C:
			// draw a line
			drawModeC();
			break;
			
		default:
			// draw the controls
			if (controlTab == CONTROL_TAB_DRAWING) {
				sensorButton.draw();
				drawingButton.draw();
				drawingGui.draw();
				sensorGui.draw(); // draw both for now
				drawDebugData();
			}
			else if (controlTab == CONTROL_TAB_SENSOR) {
				sensorButton.draw();
				drawingButton.draw();
				sensorGui.draw();
				drawDebugData();
			}
			break;
	}
}

//--------------------------------------------------------------
void ofApp::drawModeA() {
	
	ofPushStyle();
	
	// set colour based on gradient
	int x = ofMap(currentSize, minSize, maxSize, 1, 300);
	ofSetColor( gradients[activeGradient].getColor(x, 1) );
	
	// draw a circle in the middle of the screen
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, currentSize);
	ofSetColor(0, 0, 0);
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, currentSize-lineWeight);
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::drawModeB() {
	
	ofPushStyle();
	
	// set colour based on gradient
	int x = ofMap(currentSize, minSize, maxSize, 1, 300);
	ofSetColor( gradients[activeGradient].getColor(x, 1) );
	
	// draw a circle but use the maxSize
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, maxSize);
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::drawModeC() {
	
	ofPushStyle();
	
	ofSetColor( 255,255,255 );
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, maxSize);
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::drawDebugData() {
	// draw debugging data
	ofSetColor(255);
	
	ofPushMatrix();
	
	ofTranslate(10, 360);
	ofDrawBitmapStringHighlight("Magnetometer (x,y,z):", 0, 0);
	ofVec3f m = coreMotion.getMagnetometerData();
	ofDrawBitmapString(ofToString(m.x), 0, 20);
	ofDrawBitmapString(ofToString(m.y), 100, 20);
	ofDrawBitmapString(ofToString(m.z), 200, 20);
	
	ofTranslate(0, 40);
	ofDrawBitmapStringHighlight("Magnitude (act,-rest):", 0, 0);
	ofDrawBitmapString(ofToString(magnitude), 0, 20);
	ofDrawBitmapString(ofToString(magnitude - restSensor), 100, 20);
	
	ofTranslate(0, 40);
	ofDrawBitmapStringHighlight("Sensor (rest,min,max):", 0, 0);
	ofDrawBitmapString(ofToString(restSensor), 0, 20);
	
	// show if the value is outside the range
	ofPushStyle();
	if (minSensor < minRange) ofSetColor(255, 0, 0);
	ofDrawBitmapString(ofToString(minSensor), 100, 20);
	ofPopStyle();
	
	// show if the vaue is outside the range
	ofPushStyle();
	if (maxSensor > maxRange) ofSetColor(0, 255, 0);
	ofDrawBitmapString(ofToString(maxSensor), 200, 20);
	ofPopStyle();
	
	ofPopMatrix();
}

//--------------------------------------------------------------
void ofApp::drawColourPicker() {
	
	// draw overlay
	ofSetColor(128, 0, 128, 128);
	ofRect(0, 0, ofGetWidth(), ofGetHeight());
	
	// draw the NONE option
	ofPushStyle();
	ofSetColor(0, 0, 0);
	ofRect(10, 10, 300, 40);
	ofNoFill();
	ofSetColor(128, 128, 128);
	ofRect(10, 10, 300, 40);
	ofSetColor(255, 0, 0);
	ofLine(10, 50, 310, 10);
	ofPopStyle();
	
	// draw gradients
	ofSetColor(255, 255, 255);
	
	for (int i = 0; i < NUM_GRADIENTS; i++) {
		gradients[i].draw(10, 60 + (i*50) );
	}
	
	ofPushStyle();
	ofNoFill();
	
	// highlight the grad
	ofRect(10, 60 + (activeGradient*50), 300, 40);
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::resetSensorButtonPressed() {
	restSensor = magnitude;
	minSensor = maxSensor = 0;
	ofLogNotice("reset sensor");
}

//--------------------------------------------------------------
void ofApp::updateSensorButtonPressed() {
	minRange.set(minSensor);
	maxRange.set(maxSensor);
	ofLogNotice("update sensor");
}

//--------------------------------------------------------------
void ofApp::colourPickerButtonPressed() {
//	displayMode = STATE_DEBUG_COLOUR;
	ofLogNotice("displayMode is STATE_COLOUR_PICKER");
}

//--------------------------------------------------------------
void ofApp::exit(){
	resetSensorButton.removeListener(this,&ofApp::resetSensorButtonPressed);
	updateSensorButton.removeListener(this,&ofApp::updateSensorButtonPressed);
	colourPickerButton.removeListener(this,&ofApp::colourPickerButtonPressed);
	
	ofLogNotice("exit");
	
	// save the current settings
	XML.setValue("SENSOR:RANGE:LOW", minRange);
	XML.setValue("SENSOR:RANGE:HIGH", maxRange);
	XML.setValue("SENSOR:REST", restSensor);
	XML.setValue("SHAPE:SIZE:MIN", minSize);
	XML.setValue("SHAPE:SIZE:MAX", maxSize);
	XML.setValue("GRADIENT:ACTIVE_INDEX", activeGradient);
	XML.setValue("SHAPE:BLINK:MIN", blinkSlowSpeed);
	XML.setValue("SHAPE:BLINK:MAX", blinkFastSpeed);
	
	if ( XML.saveFile( ofxiOSGetDocumentsDirectory() + XML_SETTINGS_FILE) ) {
		ofLogNotice("saved settings to app documents folder");
	}
	else {
		ofLogNotice("unable to save settings");
	}
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
	
	followTouch = true;
	lastTouchPoint.set(touch.x, touch.y);
	
	// check and select colour
	/*if (displayMode == STATE_DEBUG_COLOUR) {
		ofRectangle r = ofRectangle(10,10,300,40);
		if (r.inside(touch.x, touch.y)) {
//			bNoGradient = true;
			return;
		}
		ofLogNotice("skip this?");
		for (int i = 0; i < NUM_GRADIENTS; i++) {
			r.set(10, 60+(i*50), 300, 40);
			
			if (r.inside(touch.x, touch.y)) {
				activeGradient = i;
//				bNoGradient = false;
				ofLogNotice("activeGradient = " + ofToString(activeGradient));
			}
		}
	}
	else if (displayMode == STATE_DEBUG_SENSOR) {
		if (drawingButton.inside(touch.x, touch.y)) {
//			displayMode = STATE_DEBUG_DRAWING;
			sensorButton.active = false;
			drawingButton.active = true;
			ofLogNotice("state is DEBUG DRAWING");
		}
	}
	else if (displayMode == STATE_DEBUG_DRAWING) {
		if (sensorButton.inside(touch.x, touch.y)) {
//			displayMode = STATE_DEBUG_SENSOR;
			sensorButton.active = true;
			drawingButton.active = false;
			ofLogNotice("state is DEBUG SENSOR");
		}
	}*/
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
	
	if (followTouch) {
		
		if ( (lastTouchPoint.x - touch.x) > 50 ) {
			ofLogNotice("swipe left");
			followTouch = false;
		}
		else if ( (lastTouchPoint.x - touch.x) < -50 ) {
			ofLogNotice("swipe right");
			followTouch = false;
		}
		else if ( (lastTouchPoint.y - touch.y) > 50 ) {
			ofLogNotice("swipe up");
			followTouch = false;
		}
		else if ( (lastTouchPoint.y - touch.y) < -50 ) {
			ofLogNotice("swipe down");
			followTouch = false;
		}
		
		lastTouchPoint.set(touch.x, touch.y);
	}
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
	followTouch = false;
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
	if (drawingMode == 0) {
		// currently showing controls
		drawingMode = DRAWING_MODE_A;
		ofLogNotice( "hide the controls" );
	} else {
		// currently drawing
		controlTab = CONTROL_TAB_DRAWING;
		drawingMode = 0;
		ofLogNotice( "show the controls" );
	}
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
	followTouch = false;
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
	ofLogNotice("lostFocus");
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
	ofLogNotice("gotFocus");
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
	
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
	ofLogNotice("deviceOrientationChanged, new = " + ofToString(newOrientation)	);
}