#include "RectBlobDetect.h"
#include "Camera.hpp"
#include "Renderer.hpp"
#include "Utils.hpp"
#include "Noise.hpp"
#include "CameraManager.h"
#include "TextRect.hpp"


#define PIXEL_SKIP 3
#define MAX_BLOB_SIZE 101
#define INCLUSION_DISTANCE 4
//should be at least PIXEL_SKIP or PIXEL_SKIP * some multiple

//INPUT_MODE : image = 0, video = 1, camera = 2
#define INPUT_MODE 2

#define USE_RGB_THRESHOLDS 1

#include <glm/gtc/matrix_transform.hpp>
#include <iostream> 
#include <sstream>
#include <glm/gtx/string_cast.hpp>




RectBlobDetect::RectBlobDetect() {
  
  useTexCoords = true;
  
  ResourceHandler* rh = ResourceHandler::GetResourceHandler();
  
  if (INPUT_MODE == 0) {
    videoTexture = rh->CreateTextureFromImageFile("blobTest1.png");
  } else if (INPUT_MODE == 1) {
    videoTexture = rh->CreateVideoTexture("testvid.m4v", false, false, true);
    //videoTexture = rh->CreateVideoTexture("AlloPano5Mbps.mov",  false, false, true);
  } else if (INPUT_MODE == 2) {
    videoTexture = rh->CreateVideoCaptureTexture(); //pass in resolution, also camera (front or back)!
  } else {
    printf("in RectBlobDetect::RectBlobDetect, input mode not valid\n");
    return;
  }
 
  videoTexture->SetFilterModes(GL_NEAREST,GL_NEAREST);
  
  wScale = 1.0/videoTexture->width;
  hScale = 1.0/videoTexture->height;
  
  filterTexture = Texture::CreateEmptyTexture(videoTexture->width, videoTexture->height);
  
  int blobDisplayScale = 1; //make sure not bigger this wont make the texture > than max_texture_size
  Texture* t = Texture::CreateSolidTexture(ivec4(0,0,0,255),videoTexture->width * blobDisplayScale, videoTexture->height * blobDisplayScale);
  
  //t->SetFilterModes(GL_LINEAR,GL_LINEAR);
  fbo = new FBO(t);
  
  InitializeBlobShapes();
    
}

void RectBlobDetect::InitializeBlobShapes() {
  blobRect = new Rectangle();
  blobRect->useTexCoords = false;
  blobRect->Transform();
  
  blobCircle = new Circle();
  blobCircle->useTexCoords = false;
  blobCircle->Transform();
}


bool RectBlobDetect::CheckIfLegalBlob(Blob* b, BlobThreshold* bt) {
  
  int size = b->CalculateSize(); 
    
  //printf("blob size is %d\n, min/maxBlobSize = %d/%d\n", size, bt->minBlobSize,  bt->maxBlobSize);
  if (size < bt->minBlobSize) { // || size > bt->maxBlobSize) {
   //printf("Reject...\n");
    return false;
  }
  
  float density = b->CalculateDensity(PIXEL_SKIP);
  //printf("density is %f\n, min/maxDenisity = %f/%f\n",density, bt->minDensity, bt->maxDensity);
  
  if ( density < bt->minDensity || density > bt->maxDensity) {
   //printf("Reject...\n");
    
    return false;
  }
  
  //printf("Accept...\n");
  return true;
  
}


mat4 RectBlobDetect::CalculateRectMV(Blob* b) {
  mat4 blobGeomMV = mat4();
  blobGeomMV = glm::translate(blobGeomMV, vec3(b->left * wScale, b->bottom * hScale, 0.0));
  blobGeomMV = glm::scale(blobGeomMV, vec3((b->right - b->left + 1) * wScale, (b->top - b->bottom + 1) * hScale, 1.0));
  
  return blobGeomMV;
}

mat4 RectBlobDetect::CalculateCircleMV(Blob* b) {
  
  mat4 blobGeomMV = mat4();
  float circleDim = min((b->right - b->left + 1) * wScale , (b->top - b->bottom + 1) * hScale);
  
  // blobGeomMV = mat4::Translate(blobGeomMV, 0.5, 0.5, 0.0);
  
  blobGeomMV = glm::translate(blobGeomMV, 
                              vec3( 
                                   ((b->left + b->right + 1) / 2) * wScale, 
                              
                                   ((b->bottom + b->top + 1) / 2) * hScale, 
                                   0.0) );
  
  if (INPUT_MODE == 2) {
    blobGeomMV = glm::scale(blobGeomMV, vec3( circleDim * 0.5 * root->aspect, circleDim * 0.5, 1.0));
  } else {
    blobGeomMV = glm::scale(blobGeomMV, vec3( circleDim * 0.5 , circleDim * 0.5 * root->aspect, 1.0));
  }
  
  return blobGeomMV;
}



void RectBlobDetect::DetermineLargestBlobs(BlobThreshold* bt, int maxNumBlobs) {
  blobs.sort(Blob::CompareBlobsBySize); 
  prevBlobs.clear(); 
  int blobIdx = 0;
  
  list<Blob*>::iterator itA = blobs.begin();
  for(itA = blobs.begin(); itA != blobs.end(); ++itA) {
    //printf("blob... %d\n", (*itA)->CalculateSize());
    Blob* currentBlob = (*itA);
    if ( CheckIfLegalBlob( currentBlob, bt ) == false) {
      continue;
    }
    
    prevBlobs.push_back(currentBlob);
    blobIdx++;

    if (blobIdx == maxNumBlobs) {
      break;
    }
  }

}

void RectBlobDetect::DetermineCurrentBlobs(BlobThreshold* bt) {
  
  //float averageLuma = AverageLuma(videoTexture, PIXEL_SKIP);
  
  
  
  // printf("\n\n********\n");
  
  list<Blob*>::iterator itP = prevBlobs.begin();
  for(itP = prevBlobs.begin(); itP != prevBlobs.end(); ++itP) {
    (*itP)->markedForChecking = false;
  }
  
  blobs.sort(Blob::CompareBlobsBySize); 
  
  int numLegalBlobs = 1;
  int blobIdx = 0;
  
  list<Blob*>::iterator itA = blobs.begin();
  for(itA = blobs.begin(); itA != blobs.end(); ++itA) {
    //printf("blob... %d\n", (*itA)->CalculateSize());
    Blob* currentBlob = (*itA);
    if ( CheckIfLegalBlob( currentBlob, bt ) == false) {
      continue;
    }
    
    Blob* closestPrevBlob = currentBlob->GetClosestBlobToBlob( prevBlobs );
    
    
    if (closestPrevBlob == NULL) {
      prevBlobs.push_back(currentBlob);
      blobIdx++;
    }
    
    else {
      ivec2 prevCentroid = closestPrevBlob->GetCentroid();
      ivec2 currCentroid = currentBlob->GetCentroid();
      
      //      int xDist = (currCentroid.x - prevCentroid.x);
      //      int yDist = (currCentroid.y - prevCentroid.y);
      int xDist = -(closestPrevBlob->left - currentBlob->left);
      int yDist = -(closestPrevBlob->bottom - currentBlob->bottom);
      
      float rads = atan2(yDist, xDist);
      int xInc = (int) abs(cos(rads) * 3.0);
      int yInc = (int) abs(sin(rads) * 3.0);
      xInc = 1;
      yInc = 1;
      
      if (xDist > 1) {
        closestPrevBlob->left += xInc; //min(xInc, abs(closestPrevBlob->left - currentBlob->left));
        closestPrevBlob->right += xInc;
      } else if (xDist < 1) {
        closestPrevBlob->left -= xInc; //min(xInc, abs(closestPrevBlob->left - currentBlob->left));
        closestPrevBlob->right -= xInc;
      }
      
      if (yDist > 1) {
        closestPrevBlob->bottom += yInc;
        closestPrevBlob->top += yInc;
      } else if (yDist < 1) {
        closestPrevBlob->bottom -= yInc;
        closestPrevBlob->top -= yInc;
      }
      
      int wInc = (int) (abs(closestPrevBlob->GetWidth() - currentBlob->GetWidth()) * 0.1);
      int hInc = (int) (abs(closestPrevBlob->GetHeight() - currentBlob->GetHeight()) * 0.1);
      wInc = 1;
      hInc = 1;
      if (currentBlob->GetWidth() > closestPrevBlob->GetWidth() + 0 ) {
        //closestPrevBlob->left -= wInc;
        closestPrevBlob->right += wInc;
      } else if (currentBlob->GetWidth() < closestPrevBlob->GetWidth() ) {
        //closestPrevBlob->left += wInc;
        closestPrevBlob->right -= wInc;      }    
      
      if (currentBlob->GetHeight() > closestPrevBlob->GetHeight() + 0) {
        //closestPrevBlob->bottom -= hInc;
        closestPrevBlob->top += hInc;
      } else if (currentBlob->GetHeight() < closestPrevBlob->GetHeight() ) {
        //closestPrevBlob->bottom += hInc;
        closestPrevBlob->top -= hInc;
      }  
      
      
      blobIdx++;
    }
    
    if (blobIdx == numLegalBlobs) {
      break;
    }
  }
  
  //now prob want to loop through the prevBlobs that weren't marked for checking and shrink them & if < a certain size, remove them.
  
  list<Blob*>::iterator i = prevBlobs.begin();
  
  while (i != prevBlobs.end()) {
    Blob* b = (*i);
    
    if (b->markedForChecking == false) {
      int wInc = (int) (b->GetWidth() * 0.1);
      int hInc = (int) (b->GetHeight() * 0.1);
      wInc = 1;
      hInc = 1;
      // b->bottom += wInc;
      b->top -= wInc;
      
      //  b->left += hInc;
      b->right -= hInc;
    }
    
    if (b->GetWidth() <= 1 || b->GetHeight() <= 1) {
      prevBlobs.erase(i++);  
    }
    else {
      ++i;
    }
  }
}

void RectBlobDetect::Draw() {
  
  Program* program;
  ResourceHandler* rh = ResourceHandler::GetResourceHandler();
  
  if (INPUT_MODE == 1) {
    rh->NextVideoFrameLock();
  }
  
  HandleSelectedPixel();
  
  //need to iterate through all of these...
  BlobThreshold* bt = infoPanel->currentThreshold;
  BlobDetect(videoTexture, bt);
  
  DetermineLargestBlobs(bt, 3);
 // DetermineCurrentBlobs(bt);
  
  
    
  
 // printf("********\n\n");
  
      
  
  Geom* blobGeom = blobCircle;
  Geom* blobGeom2 = blobRect;
  
  program = GetProgram("FlatShader");
  
  
  fbo->Bind(); {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); 
    
    
    program->Bind(); {
      
      list<Blob*>::iterator it;
      for(it = prevBlobs.begin(); it != prevBlobs.end(); ++it){
        
        Blob* blob = (*it);
        mat4 blobGeomMV = CalculateCircleMV(blob);
        
        
       // glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, glm::value_ptr(mat4()));
        glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, glm::value_ptr(blobGeomMV));
        glUniformMatrix4fv(program->Uniform("Projection"), 1, 0, glm::value_ptr(root->projection));
        glUniform4fv(program->Uniform("Color"), 1, glm::value_ptr(vec4(0,0,1,1)));
        blobGeom->PassVertices(program, GL_TRIANGLES);
        blobGeomMV = CalculateRectMV(blob);
        
        
       // glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, mat4::Identity().Pointer());
        glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, glm::value_ptr(blobGeomMV));
        glUniformMatrix4fv(program->Uniform("Projection"), 1, 0, glm::value_ptr(root->projection));
        glUniform4fv(program->Uniform("Color"), 1, glm::value_ptr(vec4(0,1,0,1)));
        blobGeom2->PassVertices(program, GL_LINES);
      }
    }program->Unbind();
  } fbo->Unbind();
  
  
  
  
  
  Renderer::GetRenderer()->BindDefaultFrameBuffer();
  ivec4 vp = root->viewport;
  glViewport(vp.x, vp.y, vp.z, vp.w);
  
  //needs to be done to handle weird camera orientation! (only works when camera locked right now... revisit)
  ROT_MV = modelview; 
  
  if (INPUT_MODE == 2) {
    ROT_MV = glm::translate(ROT_MV, vec3(0.5, 0.5, 0.0));
    
    ROT_MV = glm::rotate(ROT_MV, 180.0f, vec3(0.0,1.0,0.0) );
    ROT_MV = glm::rotate(ROT_MV, 90.0f, vec3(0,0,1));
    ROT_MV = glm::translate(ROT_MV, vec3(-0.5, -0.5, 0.0));
  }                
  
  glEnable(GL_BLEND);
  glBlendFunc( GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR );
  
  program = GetProgram("SingleTexture");
  program->Bind(); {
    
    // glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, modelview.Pointer());
    glUniformMatrix4fv(program->Uniform("Modelview"), 1, 0, glm::value_ptr(ROT_MV));
    glUniformMatrix4fv(program->Uniform("Projection"), 1, 0, glm::value_ptr(root->projection));
  
    
    videoTexture->Bind(GL_TEXTURE0); {
      glUniform1i(program->Uniform("s_tex"), 0);
      PassVertices(program, GL_TRIANGLES);
    } videoTexture->Unbind(GL_TEXTURE0);
   
    
    filterTexture->Bind(GL_TEXTURE0); {
      glUniform1i(program->Uniform("s_tex"), 0);
      PassVertices(program, GL_TRIANGLES);
    } filterTexture->Unbind(GL_TEXTURE0);
   
    
    fbo->texture->Bind(GL_TEXTURE0); {
      glUniform1i(program->Uniform("s_tex"), 0);
      PassVertices(program, GL_TRIANGLES);
    } fbo->texture->Unbind(GL_TEXTURE0);
       
  } program->Unbind();
  
  rh->NextVideoFrameUnlock();
}


bool RectBlobDetect::PixelWithinLumaThresholds(ivec4 pixel, BlobThreshold* bt) {
  int luma = Color::Luma(pixel);
  
  if (luma >= bt->minLuma && luma <= bt->maxLuma) {
    return true;
  }
  
  return false;
}


bool RectBlobDetect::PixelWithinRGBThresholds(ivec4 pixel, BlobThreshold* bt) {
  
  if (pixel.x >= bt->minRed && pixel.x <= bt->maxRed &&
      pixel.y >= bt->minGreen && pixel.y <= bt->maxGreen &&
      pixel.z >= bt->minBlue && pixel.z <= bt->maxBlue ) {
    return true;
  }
  
  return false;
}

bool RectBlobDetect::PixelWithinThresholds(ivec4 pixel, BlobThreshold* bt) {
  if (USE_RGB_THRESHOLDS == 1) {
    return PixelWithinRGBThresholds(pixel, bt);
  } else {
    return PixelWithinLumaThresholds(pixel, bt);
  }
}


void RectBlobDetect::BlobDetect(Texture *t, BlobThreshold* bt) {
  
  filterTexture->FillRectAt(0,0,filterTexture->width, filterTexture->height, ivec4(0,0,0,255));
  
  ivec4 pixel;
  blobs.clear();
  
  list<Blob*> newBlobs;
  list<Blob*>::iterator blobIter;
  
  for (int y = 0; y < t->height; y+=PIXEL_SKIP) {
    for (int x = 0; x < t->width; x+=PIXEL_SKIP) {
      
      if(PixelWithinThresholds(t->GetPixelAt(x, y), bt)) {
      
        newBlobs.clear();
        checkBlobs.clear();
        
        int rectSize = max(1,PIXEL_SKIP/2);
        filterTexture->DrawRectAt(x-rectSize,y-rectSize,PIXEL_SKIP, PIXEL_SKIP, ivec4(255,255,255,255));
        
        //filterTexture->SetPixelAt(x, y, ivec4(255,255,255,255));
        
        for(blobIter = blobs.begin(); blobIter != blobs.end(); ++blobIter) {
          
          
          if ((*blobIter)->AddPixel(ivec2(x,y)) == true) {
            checkBlobs.push_back((*blobIter));
          }
        }
        
        //new blob?
        if (checkBlobs.size() == 0) {
          //fbo->texture->SetPixelAt(x,y,ivec4(0,255,0,255)); 
          //  videoTexture->SetPixelAt(x,y,ivec4(0,255,0,255)); 
          
          //printf("\t new blob at %d %d\n", x, y);
          newBlobs.push_back( new Blob(ivec2(x,y), INCLUSION_DISTANCE, MAX_BLOB_SIZE) );
        }
        
        
        //merge these blobs
        else if (checkBlobs.size() > 1) {
          //fbo->texture->SetPixelAt(x,y,ivec4(255,0,0,255)); 
          // videoTexture->SetPixelAt(x,y,ivec4(255,0,0,255)); 
          newBlobs.push_back(Blob::MergeBlobs(checkBlobs, INCLUSION_DISTANCE, MAX_BLOB_SIZE));
        }
        
        
        // list<Blob*>::iterator blobIter2;
        
        // Blob* biggestBlob;
        
        int ccc = 0;
        for(blobIter = blobs.begin(); blobIter != blobs.end(); ++blobIter) {
          
          //printf("BLOB %d\n", ccc++);
          
          if ((*blobIter)->markedForRemoval == false) {
            newBlobs.push_back(*blobIter);
          } else {
            delete *blobIter;
          }
        }
        
        //  printf("new Blobs size = %lu\n", newBlobs.size());
        
        blobs = newBlobs;
      } 
      
    }
  } 
  
}

int RectBlobDetect::AverageLuma(Texture* t, int sampleSkip) {
  
  float luma = 0;
  int sampleTotal = 0;
  
  for (int y = 0; y < t->height; y+=sampleSkip) {
    for (int x = 0; x < t->width; x+=sampleSkip) {
      luma += Color::Luma(t->GetPixelAt(x,y)); 
      sampleTotal++;
    }
  }
  
  return (int)((float)luma / (float)(sampleTotal));
}

void RectBlobDetect::HandleTouchBegan(ivec2 mouse) {
  ChooseSelectedPixel(mouse);
}

void RectBlobDetect::HandleSelectedPixel() {
  if (pixelSelected == false) {
    return;
  }
  
 // pixelPt.Print("Pixel coords = ");
  ivec4 pixel = videoTexture->GetPixelAt(pixelPt.x, videoTexture->height - pixelPt.y);
 // pixel.Print("PIXEL is ");
  
  infoPanel->UpdateCurrentThreshold(new Color(pixel));
  
  
  pixelSelected = false;
  //filterTexture->SetRectAt(pixelPt.x, videoTexture->height - pixelPt.y, 100,100, pixel);
}


void RectBlobDetect::ChooseSelectedPixel(ivec2 mouse) {
  
  vec3 objPt = glm::unProject(vec3(mouse.x, mouse.y, 0), ROT_MV, root->projection, root->viewport);
  cout << "in RectBlobDetect : mouse in 3D Coords = " << glm::to_string(objPt) << "\n";
  
 // cout << "ROT_MV = " << glm::to_string(ROT_MV) << "\n";
  // objPt.Print("RectBlobDetect : mouse in 3D Coords = ");
  
  pixelPt = ivec2(objPt.x * videoTexture->width, objPt.y * videoTexture->height);
  cout << "in RectBlobDetect : pixelPt = " << glm::to_string(pixelPt) << "\n";
  
  if (pixelPt.x < 0 || pixelPt.x >= videoTexture->width || pixelPt.y < 0 || pixelPt.y > videoTexture->height) {
    pixelSelected = false;
    return;
  }
  
  pixelSelected = true;
}

void RectBlobDetect::HandleTouchMoved(ivec2 prevMouse, ivec2 mouse) {
  
  ChooseSelectedPixel(mouse);

}

void RectBlobDetect::AttachController(ContainerBlobInfo* _c) {
  infoPanel = _c;
}


