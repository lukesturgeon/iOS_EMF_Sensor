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
	
	float mSize = ofGetWidth()/2;
	
	
	
	//-
	setRestButton.set( 320, 0, 320, 100 );
	setRestButton.setLabel("REST");
	useMinMaxButton.set( 320, 100, 320, 100 );
	useMinMaxButton.setLabel("USE MIN MAX");
	
	minSizeSlider.set(XML.getValue("SHAPE:SIZE:MIN", 0), 0, mSize);
	minSizeSlider.setRect( 0, 512, 320, 60 );
	
	maxSizeSlider.set(XML.getValue("SHAPE:SIZE:MAX", mSize), 0, mSize);
	maxSizeSlider.setRect( 0, 512+60, 320, 60 );
	//-
	
	sensorGui.setup("Sensor");
	sensorGui.add(minRange.set("low", XML.getValue("SENSOR:RANGE:LOW", 0), -2000, 0));
	sensorGui.add(maxRange.set("high", XML.getValue("SENSOR:RANGE:HIGH", 1), 1, 2000));
	
	drawingGui.setup("Drawing");
	drawingGui.add(minSize.set("minSize", XML.getValue("SHAPE:SIZE:MIN", 0), 0, mSize));
	drawingGui.add(maxSize.set("maxSize", XML.getValue("SHAPE:SIZE:MAX", mSize), 0, mSize));
	drawingGui.add(blinkSlowSpeed.set("blinkSlow", XML.getValue("SHAPE:BLINK:MIN", 1000), 10, 1000));
	drawingGui.add(blinkFastSpeed.set("blinkFast", XML.getValue("SHAPE:BLINK:MAX", 10), 10, 1000));
	
	// setup starting values
	restSensor = XML.getValue("SENSOR:REST", 0);
	activeGradient = XML.getValue("GRADIENT:ACTIVE_INDEX", 0);
	bBlinkOn = false;
	blinkSlowSpeed.set(1000);
	blinkFastSpeed.set(50);
	lineWeight.set(10); // default line weight
	drawingMode = DRAWING_MODE_A;
	
	// setup sensor
    coreMotion.setupMagnetometer();
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
				setRestButton.draw();
				useMinMaxButton.draw();
				drawingGui.draw();
				sensorGui.draw(); // draw both for now
				drawColourPicker(); // draw all for now
				drawDebugData();
				minSizeSlider.draw();
				maxSizeSlider.draw();
			}
			else if (controlTab == CONTROL_TAB_SENSOR) {
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
	
	ofPushStyle();
	
	ofSetColor(255);
	
	// draw gradients
	for (int i = 0; i < NUM_GRADIENTS; i++) {
		gradients[i].draw(0, (i*60), 60, 60 );
	}
	
	// highlight the grad
	ofNoFill();
	ofSetLineWidth(5);
	ofRect(0, (activeGradient*60), 60, 60);
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::saveSettings(){
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
void ofApp::exit(){
	ofLogNotice("exit");
	saveSettings();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
	followTouch = true;
	lastTouchPoint.set(touch.x, touch.y);
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
	
	if ( setRestButton.inside(touch.x, touch.y) ) {
		restSensor = magnitude;
		minSensor = maxSensor = 0;
		ofLogNotice("rest sensor");
	}
	else if ( useMinMaxButton.inside(touch.x, touch.y) ) {
		minRange.set(minSensor);
		maxRange.set(maxSensor);
		ofLogNotice("update sensor");
	}
	else {
		
		ofRectangle r = ofRectangle();
		for (int i = 0; i < NUM_GRADIENTS; i++) {
			
			r.set(0, (i*60), 60, 60);
			
			if (r.inside(touch.x, touch.y)) {
				activeGradient = i;
				ofLogNotice("activeGradient = " + ofToString(activeGradient));
			}
		}
	}
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
	saveSettings();
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