
#include "TextDemo.hpp"
#include "Rectangle3D.hpp"


float PINCH_SCALE = 0.001; //0.001; //this should depend on the total number of slices
//TextDemo::TextDemo() {
//  printf("in TextDemo constructor\n");
//}

void TextDemo::Initialize() {
  
  printf("in TextDemo::Initialize() : w/h = %d/%d\n", width, height); 
  SetCamera(new Camera(ivec4(0, 0, width, height)));
  
  BindDefaultFrameBuffer();
  
  camera->Transform();
  fullScreenRect->Transform();
}


float sssX = 0.0;
void TextDemo::Render() { 
  
  BindDefaultFrameBuffer();
  
  bool cameraMoved = false;
  if (camera->IsTransformed()) {
    camera->Transform();
    cameraMoved = true;
  }
  
  FontAtlas* font = GetFont("Univers128");
  font->Bind(); {
    //Text(0, sssX, "abcdefægh", vec4(1.0,0.0,0.0,0.9), false );
  } font->Unbind();
  
  font = GetFont("CMUSerifUprightItalic60");
  font->Bind(); {
    Text(0.27, 0.5, "Hello World!", vec4(1.0,1.0,1.0,0.8) );
  } font->Unbind();
  
  //Text(GetFont("CMUSerifUprightItalic128"), 100, 0.2, "H", vec4(0.0,0.0,1.0,1.0), true);
  //    GetFont("Univers128")->Text(0, 100, "abcdefægh", vec4(1.0,1.0,0.0,0.5), true );
  
  //f2->print(GetPrograms()["FontTexture"], camera, "xizwz12xg0", -0.0, 0.0 ,0, -1, 1.0);
  //    f2->print(GetPrograms()["FontTexture"], camera, "oooooo", sssX - 1.0, 0.2 ,0, 0, 1.0);
  //    f2->print(GetPrograms()["FontTexture"], camera, "111XXX", 2.0 - sssX, -0.2 ,0, 1, 1.0);
  sssX += 0.01;
  //    
  sssX = fmodf((float)sssX,2.0);
  //    
  //    //f2->print(GetPrograms()["FontTexture"], camera, "gwiw10wer", -0.5,-0.25, 0, 0, 1.0);
  
  return;
  
}

