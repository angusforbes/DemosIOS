#include "PixelList.h"
#include "Camera.hpp"




PixelList::PixelList(Container* _c) {
  container = _c;
  
  numPixels = 3;
  selectedPixel = 0;
  
  pixel0_on = true;
  pixel1_on = true;
  pixel2_on = true;
  
  pixel0 = Color::RGB(255,0,0);
  pixel1 = Color::RGB(0,255,0);
  pixel2 = Color::RGB(0,0,255);
  borderColor = Color::RGB(255);
//  handleW = 0.95;
//  handleH = 0.1;
  
  backgroundColor = NULL;
}

/*
void PixelList::SetHandleModelViews() {
  
  mvBk = mat4(GetModelView());
  mvBk = mat4::Translate(mvBk, 0.5,(maxVal + minVal)/2.0,0.0);
  mvBk = mat4::Scale(mvBk, handleW,maxVal-minVal,1.0);
  mvBk = mat4::Translate(mvBk, -0.5,-0.5,0.0);
  
  mvMin = mat4(GetModelView());
  mvMin = mat4::Translate(mvMin, 0.5,minVal,0.0);
  mvMin = mat4::Scale(mvMin, handleW,handleH,1.0);
  mvMin = mat4::Translate(mvMin, -0.5,-0.5,0.0);
  
  mvMax = mat4(GetModelView());
  mvMax = mat4::Translate(mvMax, 0.5,maxVal,0.0);
  mvMax = mat4::Scale(mvMax, handleW,handleH,1.0);
  mvMax = mat4::Translate(mvMax, -0.5,-0.5,0.0);  
}
*/

/*
void PixelList::DrawElement(mat4 mv, Color* color) {
  
  Program* p = GetProgram("FlatShader");
  p->Bind(); {
    glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, mv.Pointer());
    glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, root->projection.Pointer());
    
    glUniform4fv(p->Uniform("Color"), 1, color->AsFloat().Pointer());
    
    PassVertices(p, GL_TRIANGLES);
  } p->Unbind();
}
*/

void PixelList::DrawPixel(mat4 mv, Color* c) {
  Program* p = GetProgram("FlatShader");
  p->Bind(); {
    glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, glm::value_ptr(mv));
    glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, glm::value_ptr(root->projection));    
    glUniform4fv(p->Uniform("Color"), 1, glm::value_ptr(c->AsFloat()));
    PassVertices(p, GL_TRIANGLES);
                 glUniform4fv(p->Uniform("Color"), 1, glm::value_ptr(borderColor->AsFloat()));
    PassVertices(p, GL_LINES);
  }
}

void PixelList::Draw() {
  glEnable(GL_BLEND);
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  
  bool tmp_p0_on = pixel0_on;
  bool tmp_p1_on = pixel1_on;
  bool tmp_p2_on = pixel2_on;
  
  
  float posInc = 0.25;
  for (int i = 0; i < numPixels; i++) {
  
    mat4 mv0 = mat4(GetModelView());
    mv0 = glm::translate(mv0, vec3(0.0, 1.0 - (posInc * (i+1)), 0.0));
    mv0 = glm::scale(mv0, vec3(1.0,.25,1.0));
    
    if (tmp_p0_on == true) {
      DrawPixel(mv0, pixel0);
      tmp_p0_on = false;
      
    } else if (tmp_p1_on == true) {
      DrawPixel(mv0, pixel1);
      tmp_p1_on = false;
      
    } else {
      DrawPixel(mv0, pixel2);
      tmp_p2_on = false;
      
    }

  
  
  }
  
  /*
  //mv0 = mat4::Translate(mv0, -0.5,-0.5, 0.0);
  
  mat4 mv1 = mat4(GetModelView());
  mv1 = mat4::Translate(mv1, 0.0,0.5,0.0);
  mv1 = mat4::Scale(mv1, 1.0,.25,1.0);
 // mv1 = mat4::Translate(mv1, -0.5,-0.5,0.0);

  mat4 mv2 = mat4(GetModelView());
  mv2 = mat4::Translate(mv2, 0.0,0.25,0.0);
  mv2 = mat4::Scale(mv2, 1.0,.25,1.0);
 // mv2 = mat4::Translate(mv2, -0.5,-0.5,0.0);

  }
   */ 
  mat4 mvMinus = mat4(GetModelView());
  mvMinus = glm::translate(mvMinus, vec3(0.0,0.0,0.0));
  mvMinus = glm::scale(mvMinus, vec3(0.5,.25,1.0));

  mat4 mvPlus = mat4(GetModelView());
  mvPlus = glm::translate(mvPlus, vec3(0.5,0.0,0.0));
  mvPlus = glm::scale(mvPlus, vec3(0.5,.25,1.0));


  Program* p = GetProgram("FlatShader");
  p->Bind(); {
    /*
    glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, mv0.Pointer());
    glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, root->projection.Pointer());    
    glUniform4fv(p->Uniform("Color"), 1, pixel0->AsFloat().Pointer());
    PassVertices(p, GL_TRIANGLES);
    glUniform4fv(p->Uniform("Color"), 1, borderColor->AsFloat().Pointer());
    PassVertices(p, GL_LINES);
    
    glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, mv1.Pointer());
    glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, root->projection.Pointer());    
    glUniform4fv(p->Uniform("Color"), 1, pixel1->AsFloat().Pointer());
    PassVertices(p, GL_TRIANGLES);
    glUniform4fv(p->Uniform("Color"), 1, borderColor->AsFloat().Pointer());
    PassVertices(p, GL_LINES);
    
    glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, mv2.Pointer());
    glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, root->projection.Pointer());    
    glUniform4fv(p->Uniform("Color"), 1, pixel2->AsFloat().Pointer());
    PassVertices(p, GL_TRIANGLES);
    glUniform4fv(p->Uniform("Color"), 1, borderColor->AsFloat().Pointer());
    PassVertices(p, GL_LINES);
    */
    glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, glm::value_ptr(mvPlus));
    glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, glm::value_ptr(root->projection));    
    glUniform4fv(p->Uniform("Color"), 1, glm::value_ptr(borderColor->AsFloat()));
    PassVertices(p, GL_LINES);
    
    glUniformMatrix4fv(p->Uniform("Modelview"), 1, 0, glm::value_ptr(mvMinus));
    glUniformMatrix4fv(p->Uniform("Projection"), 1, 0, glm::value_ptr(root->projection));    
    glUniform4fv(p->Uniform("Color"), 1, glm::value_ptr(borderColor->AsFloat()));
    PassVertices(p, GL_LINES);
    
  } p->Unbind();
  
  //if (mvMin == NULL || mvMax == NULL) {
  //SetHandleModelViews(); //really should just be done once (or when mouse moved)
  //}
 
  /*
  if (backgroundColor == NULL) {
    backgroundColor = new Color(ivec4(color->Red(), color->Green(), color->Blue(), 128));
  }
  
  DrawElement(mvBk, backgroundColor); 
  DrawElement(mvMin, color);
  DrawElement(mvMax, color);
  */
}

void PixelList::SetColor(Color* c) {
  //get selected pixel... change color of it
 // printf("in  PixelList::SetColor\n");
  
  switch(selectedPixel) {
    case 0:
      pixel0 = c;
      break;
    case 1:
      pixel1 = c;
      break;
    case 2:
      pixel2 = c;
      break;
  }
}

void PixelList::HandleTouchBegan(ivec2 mouse) {
  
  
  printf("HERE in PixelList::HandleTouchBegan\n");
  
  vec3 pt = glm::unProject(vec3(mouse.x, mouse.y, 0.0), modelview, root->projection, root->viewport);
  float y = pt.y;
  float x = pt.x;
  
  printf("y = %f\n", y);
  if (y > 0.75) {
    if (pixel0_on == true) {
      selectedPixel = 0;
    } else if (pixel1_on == true) {
      selectedPixel = 1;
    } else if (pixel2_on == true) {
      selectedPixel = 2;
    }
    printf("you selected pixel %d\n", selectedPixel);
    
  } else if (y > 0.5) {
    if (pixel1_on == true) {
      selectedPixel = 1;
    } else if (pixel2_on == true) {
      selectedPixel = 2;
    }
    printf("you selected pixel %d\n", selectedPixel);
  } else if (y > 0.25) {
    if (pixel2_on == true) {
      selectedPixel = 2;
    }
    printf("you selected pixel %d\n", selectedPixel);
  } else {
    
    if (x > 0.5) {
      printf("PLUS\n");
      
      if (numPixels < 3) {
        numPixels++;
        
        
        Color* prevColor;
        if (selectedPixel == 0) {
          prevColor = pixel0;
        } else if (selectedPixel == 1) {
          prevColor = pixel1;
        } else if (selectedPixel == 2) {
          prevColor = pixel2;
        }
        
        
        if (pixel0_on == false) {
          pixel0_on = true;
          selectedPixel = 0;
        } else if (pixel1_on == false) {
          pixel1_on = true;
          selectedPixel = 1;
        } else if (pixel2_on == false) {
          pixel2_on = true;
          selectedPixel = 2;
        } 
        
        printf("PLUSing, new selected pixel = %d\n", selectedPixel);
        
        if (selectedPixel == 0) {
          pixel0 = prevColor;
        } else if (selectedPixel == 1) {
          pixel1 = prevColor;
        } else if (selectedPixel == 2) {
          pixel2 = prevColor;
        }

      
        
        
      }
      
    } else {
      printf("MINUS\n");
      
      if (numPixels > 1) {
        if (selectedPixel == 0) {
          pixel0_on = false;
        } else if (selectedPixel == 1) {
          pixel1_on = false;
        } else if (selectedPixel == 2) {
          pixel2_on = false;
        }  
        
        printf("MINUSing pixel %d\n", selectedPixel);
        
        numPixels--;
        
        if (pixel2_on == true) {
          selectedPixel = 2;
        } else if (pixel1_on == true) {
          selectedPixel = 1;
        } else if (pixel0_on == true) {
          selectedPixel = 0;
        } 
        
        printf("MINUSing, moving selected pixel to %d\n", selectedPixel);
        
      }
    }
  }
  
  isUpdated = true;
  container->isUpdated = true;
  
}

void PixelList::HandleTouchMoved(ivec2 prevMouse, ivec2 mouse) {
  /*
  if (minValSelected) {    
    minVal = mat4::Unproject(mouse.x, mouse.y, 0.0, modelview, root->projection, root->viewport).y - offsetY;
  }
  
  else if(maxValSelected) {
    maxVal = mat4::Unproject(mouse.x, mouse.y, 0.0, modelview, root->projection, root->viewport).y - offsetY;
  }
  
  
  if (minVal > maxVal) {
    float tmp = minVal;
    minVal = maxVal;
    maxVal = tmp;
    maxValSelected = !maxValSelected; //true;
    minValSelected = !minValSelected; //false;
  }
  
  if (minVal < 0.0) { minVal = 0.0; }
  if (maxVal > 1.0) { maxVal = 1.0; }
  
  
  
  container->isUpdated = true;
  
  printf("min/max vals = %f/%f\n", minVal, maxVal);
  */
}


void PixelList::HandleTouchEnded(ivec2 mouse) {
  //printf("in DoubleSlider::HandleTouchEnded\n");
  //minValSelected = false;
  //maxValSelected = false;
}








