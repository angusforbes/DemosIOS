#include "ContainerBlobInfo.h"
#include "Renderer.hpp"
#include "TextRect.hpp"


ContainerBlobInfo::ContainerBlobInfo() {
 
  
  widgetsInstalled = false;
 
  //isUpdated = true;
}

void ContainerBlobInfo::UpdateWidgets() {
  
  
  //if we are switching to a new blob threshold
  if (pixelList->isUpdated) {
  
  switch(pixelList->selectedPixel) {
    case 0:
      currentThreshold = bt0;
      break;
    case 1:
      currentThreshold = bt1;
      break;
    case 2:
      currentThreshold = bt2;
      break;
  }
    
    UpdateSliderValues();
    pixelList->isUpdated = false;
    return;
  }
  
  //if we are using the handlebars to update the current blob threshold
  currentThreshold->minRed = (int) (doubleSliderRed->minVal * 256.0);
  currentThreshold->maxRed = (int) (doubleSliderRed->maxVal * 256.0);
  
  currentThreshold->minGreen = (int) (doubleSliderGreen->minVal * 256.0);
  currentThreshold->maxGreen = (int) (doubleSliderGreen->maxVal * 256.0);
 
  currentThreshold->minBlue = (int) (doubleSliderBlue->minVal * 256.0);
  currentThreshold->maxBlue = (int) (doubleSliderBlue->maxVal * 256.0);
  
  /*
  pixelList->SetColor(Color::RGB(
                                 (currentThreshold->minRed+currentThreshold->maxRed)/2,
                                 (currentThreshold->minGreen+currentThreshold->maxGreen)/2,
                                 (currentThreshold->minBlue+currentThreshold->maxBlue)/2));
  */
  
  currentThreshold->minDensity = doubleSliderDensity->minVal;
  currentThreshold->maxDensity = doubleSliderDensity->maxVal;
 
  //between 1 and 100?
  currentThreshold->minBlobSize = (int) (doubleSliderSize->minVal * 100.0) + 1;
  currentThreshold->maxBlobSize = (int) (doubleSliderSize->maxVal * 100.0) + 1;
  
  printf("size %d/%d, density %f/%f, blue %d/%d\n", currentThreshold->minBlobSize, currentThreshold->maxBlobSize, currentThreshold->minDensity, currentThreshold->maxDensity, currentThreshold->minBlue, currentThreshold->maxBlue);
  
  isUpdated = false;
                                 
}
void ContainerBlobInfo::InstallWidgets() {
  
  float sliderH = 0.7;
  float sliderInc = (1.0/6.0);
  
 
  bt0 = new BlobThreshold(this, Color::RGB(255,0,0));
  bt1 = new BlobThreshold(this, Color::RGB(0,255,0));
  bt2 = new BlobThreshold(this, Color::RGB(0,0,255));
  currentThreshold = bt0;
  
  /*
  Renderer::GetRenderer()->GetFont("Helvetica36")->Bind(); {
    TextRect* t1 = new TextRect("hello");
    t1->SetTranslate(0.0,0.0,0);
    t1->SetHeight(0.5);
    
    t1->SetBackgroundColor(Color::Float(0.5));
    t1->SetColor(Color::RGB(255,255,255,255));
    
    AddGeom(t1);
  }
  */
  
  //text above y=0.7
  //sliders below y=0.7
  
  
  pixelList = new PixelList(this);
  pixelList->drawBorder = true;
  pixelList->CenterAt(sliderInc * 0 + sliderInc/2.0, 0.5);
  pixelList->SetColor(currentThreshold->pixelColor);
  pixelList->SetScale(sliderInc*.75, sliderH);
  pixelList->IsSelectable = true;  
  AddGeom(pixelList);
  
  doubleSliderRed = new DoubleSlider(this);
  doubleSliderRed->CenterAt(sliderInc * 1 + sliderInc/2.0, 0.5);
  doubleSliderRed->SetColor(Color::RGB(255,0,0));
  doubleSliderRed->SetScale(sliderInc, sliderH);
  doubleSliderRed->IsSelectable = true;  
  AddGeom(doubleSliderRed);
  
  doubleSliderGreen = new DoubleSlider(this);
  doubleSliderGreen->CenterAt(sliderInc * 2 + sliderInc/2.0, 0.5);
  doubleSliderGreen->SetColor(Color::RGB(0,255,0));
  doubleSliderGreen->SetScale(sliderInc, sliderH);
  doubleSliderGreen->IsSelectable = true;  
  AddGeom(doubleSliderGreen);

  doubleSliderBlue = new DoubleSlider(this);
  doubleSliderBlue->CenterAt(sliderInc * 3 + sliderInc/2.0, 0.5);
  doubleSliderBlue->SetColor(Color::RGB(0,0,255));
  doubleSliderBlue->SetScale(sliderInc, sliderH);
  doubleSliderBlue->IsSelectable = true;  
  AddGeom(doubleSliderBlue);
    
  doubleSliderSize = new DoubleSlider(this);
  doubleSliderSize->CenterAt(sliderInc * 4 + sliderInc/2.0, 0.5);
  doubleSliderSize->SetColor(Color::RGB(0,0,255));
  doubleSliderSize->SetScale(sliderInc, sliderH);
  doubleSliderSize->IsSelectable = true;  
  AddGeom(doubleSliderSize);
  
  doubleSliderDensity = new DoubleSlider(this);
  doubleSliderDensity->CenterAt(sliderInc * 5 + sliderInc/2.0, 0.5);
  doubleSliderDensity->SetColor(Color::RGB(0,0,255));
  doubleSliderDensity->SetScale(sliderInc, sliderH);
  doubleSliderDensity->IsSelectable = true;  
  AddGeom(doubleSliderDensity);
  
  
  UpdateSliderValues();
  
  widgetsInstalled = true;
}


void ContainerBlobInfo::UpdateSliderValues() {
  UpdateSliderValues(currentThreshold);
}

void ContainerBlobInfo::UpdateSliderValues(BlobThreshold* bt) {
  doubleSliderRed->minVal = (float) (bt->minRed / 256.0);
  doubleSliderRed->maxVal = (float) (bt->maxRed / 256.0);
  
  doubleSliderGreen->minVal = (float) (bt->minGreen / 256.0);
  doubleSliderGreen->maxVal = (float) (bt->maxGreen / 256.0);
  
  doubleSliderBlue->minVal = (float) (bt->minBlue / 256.0);
  doubleSliderBlue->maxVal = (float) (bt->maxBlue / 256.0);

  doubleSliderSize->minVal = (float) (bt->minBlobSize / 100.0);
  doubleSliderSize->maxVal = (float) (bt->maxBlobSize / 100.0);

  doubleSliderDensity->minVal = (float) (bt->minDensity / 1.0);
  doubleSliderDensity->maxVal = (float) (bt->maxDensity / 1.0);

}

void ContainerBlobInfo::UpdateCurrentThreshold(Color* pixel) {
  
  pixelList->SetColor(pixel);
  currentThreshold->UpdateThresholdColor(pixel);


  UpdateSliderValues();
}


/*
void ContainerBlobInfo::SetColorThresholds(vec3 min, vec3 max) {
  
  BlobThreshold* bt;
  if (pixelList->selectedPixel == 0) {
    bt = bt0;
  } else if (pixelList->selectedPixel == 0) {
    bt = bt1;
  } else if (pixelList->selectedPixel == 0) {
    bt = bt2;
  }
 
  bt->SetColorThresholds(min, max);
}
*/

/*
void ContainerBlobInfo::SetRed(int min, int max) {
  
    
  doubleSliderRed->minVal = (float) (min / 255.0);
  doubleSliderRed->maxVal = (float) (max / 255.0);
}

ivec2 ContainerBlobInfo::GetRed() {
  return ivec2((int)(doubleSliderRed->minVal * 255.0), (int)(doubleSliderRed->maxVal * 255.0));
}

void ContainerBlobInfo::SetGreen(int min, int max) {
  doubleSliderGreen->minVal = (float) (min / 255.0);
  doubleSliderGreen->maxVal = (float) (max / 255.0);
}

ivec2 ContainerBlobInfo::GetGreen() {
  return ivec2((int)(doubleSliderGreen->minVal * 255.0), (int)(doubleSliderGreen->maxVal * 255.0));

}


void ContainerBlobInfo::SetBlue(int min, int max) {
  doubleSliderBlue->minVal =(float) (min / 255.0);
  doubleSliderBlue->maxVal =(float) (max / 255.0);
}

ivec2 ContainerBlobInfo::GetBlue() {
  return ivec2((int)(doubleSliderBlue->minVal * 255.0), (int)(doubleSliderBlue->maxVal * 255.0));

}
*/

void ContainerBlobInfo::Draw() {

  Container::Draw(); //this installs the widgets
  
  Rectangle::Draw(); //this draws the background and border (for now)
  
  

}


//void ContainerBlobInfo::HandleTouchBegan(ivec2 mouse) {}
//void ContainerBlobInfo::HandleTouchMoved(ivec2 prevMouse, ivec2 mouse) {



//}
