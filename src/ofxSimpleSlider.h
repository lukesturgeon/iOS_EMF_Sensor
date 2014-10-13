#pragma once

class ofxSimpleSlider {
	
public:
	
	ofxSimpleSlider(){
		_value = 50;
		_minValue = 0;
		_maxValue = 100;
		_rect = ofRectangle();
	}
	
	void set(float v, float min, float max){
		_value = v;
		_minValue = min;
		_maxValue = max;
	}
	
	void setRect( float px, float py, float w, float h ){
		_rect.set(px, py, w, h);
	}
	
	void draw(){
		ofSetColor(255);
		ofNoFill();
		ofRect(_rect);
		ofFill();
		ofRect(_rect.x, _rect.y, ofMap(_value, _minValue, _maxValue, 0, _rect.width), _rect.height );
	}
	
private:
	
	float _value;
	float _minValue;
	float _maxValue;
	ofRectangle _rect;
	
};