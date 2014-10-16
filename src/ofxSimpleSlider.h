#pragma once

class ofxSimpleSlider {
	
public:
	
	ofxSimpleSlider(){
		_rect = ofRectangle();
	}
	
	void setParameter( ofParameter<float> & p){
		_parameter = &p;
		_label = _parameter->getName();
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
		ofRect(_rect.x, _rect.y, ofMap(_parameter->get(), _parameter->getMin(), _parameter->getMax(), 0, _rect.width), _rect.height );
		ofSetColor(255, 0, 0);
		ofDrawBitmapString(_label, _rect.x, _rect.y + (_rect.height * 0.5f));
		
		ofPopStyle();
	}
	
	void touchDown(ofTouchEventArgs & touch){
		if ( _rect.inside( touch.x, touch.y ) ) {
			// it's definately this slider, update
			_parameter->set( ofMap(touch.x, _rect.x, _rect.x+_rect.width, _parameter->getMin(), _parameter->getMax()) );
		}
	}
	
	void touchMoved(ofTouchEventArgs & touch){
		if ( _rect.inside( touch.x, touch.y ) ) {
			// it's definately this slider, update
			_parameter->set( ofMap(touch.x, _rect.x, _rect.x+_rect.width, _parameter->getMin(), _parameter->getMax()) );
		}
	}
	
private:
	
	ofParameter<float>* _parameter;
	string _label;
	ofRectangle _rect;
	
};