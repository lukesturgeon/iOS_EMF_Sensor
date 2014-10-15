#pragma once

class ofxSimpleSlider {
	
public:
	
	ofxSimpleSlider(){
		_rect = ofRectangle();
	}
	
	void setParameter( ofParameter<float> & p){
		_parameter = &p;
		_label = _parameter->getName();
		_minValue = _parameter->getMin();
		_maxValue = _parameter->getMax();
	}
	
	void setRect( float px, float py, float w, float h ){
		_rect.set(px, py, w, h);
	}
	
	void draw(){
		
		ofPushStyle();
		
		ofSetColor(255);
		ofNoFill();
		ofRect(_rect);
		ofFill();
		ofRect(_rect.x, _rect.y, ofMap(_parameter->get(), _minValue, _maxValue, 0, _rect.width), _rect.height );
		ofSetColor(255, 0, 0);
		ofDrawBitmapString(_label, _rect.x, _rect.y);
		
		ofPopStyle();
	}
	
	void touchMoved(ofTouchEventArgs & touch){
		if ( _rect.inside( touch.x, touch.y ) ) {
			// it's definately this slider, update
			_parameter->set( ofMap(touch.x, _rect.x, _rect.x+_rect.width, _minValue, _maxValue) );
//			_parameter->set(_parameter->get());
			ofLogNotice("slider value = " + ofToString(_parameter->get()) );
		}
	}
	
private:
	
	ofParameter<float>* _parameter;
	
	string _label;
//	float _value;
	float _minValue;
	float _maxValue;
	ofRectangle _rect;
	
};