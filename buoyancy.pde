import java.util.*;

//render
float window = 0;
PVector prevDimensions;

int winDest = -1;
int shiftDir = 0; //either -1 or 1
float transitionDur = .5f;
float t = 0;

boolean render = true;

//physics
float scale = -1;
PVector gravity = new PVector(0, 150f);

Object[] objectLib = new Object[10];
ArrayList<Object> activeObjs = new ArrayList<Object>();

//window 0
Object currObj = new Object();

//window 1
float waterHeight = 0;

void setup()
{
  size(1280, 720, P2D);
  frameRate(75);

  window = -1;
  winDest = 0;
  shiftDir = 1;

  prevDimensions = new PVector(width, height);

  scale = height / 7f;
}

void draw()
{
  //input
  if (prevDimensions.x != width || prevDimensions.y != height)
  {
    prevDimensions = new PVector(width, height);
    render = true;
  }

  if (keyPressed && key == CODED)
  {
    if (keyCode == UP || keyCode == RIGHT)
    {
      if (shiftDir == 0 && window < 1)
      {
        winDest = round(window + 1);
        shiftDir = 1;
      }
    } else if (keyCode == DOWN || keyCode == LEFT)
    {
      if (shiftDir == 0 && window > 0)
      {
        winDest = round(window - 1);
        shiftDir = -1;
      }
    }
  }

  window += shiftDir * 1f / frameRate / transitionDur;
  if (shiftDir != 0)
  {    
    if (shiftDir == 1 ? window >= winDest : window <= winDest)
    {
      window = winDest;
      shiftDir = 0;
    }

    render = true;
  }



  //rendering
  t = abs(window - 0f);
  if (t < 1f)
  {
    if (render)
    {
      noStroke();
      fill(0, 15, 85, map(t, 0f, 1f, 255f, 0f));
      rect(0, 0, width, height);


      //objPanel
      PVector panelSize = new PVector((width - (objectLib.length + 1) * 5f) / objectLib.length, (width - (objectLib.length + 1) * 5f) / objectLib.length);
      float objPanelHeigth = map(t, 0f, 1f, height - panelSize.y - 10f, height + 5f);

      noStroke();
      fill(0, 128);
      rect(0, objPanelHeigth, width, panelSize.y + 10f);


      for (int i = 0; i < objectLib.length; i++)
      {
        PVector panelPos = new PVector((i * width / objectLib.length + 5f) * (width - 5f) / width, objPanelHeigth + 5f);

        noStroke();
        textSize(width / 15f);
        fill(255, 96);

        rect(panelPos.x, panelPos.y, panelSize.x, panelSize.y);
        text(i, panelPos.x + width / 37.5f, objPanelHeigth + width / 13.5f);

        if (objectLib[i] != null)
        {
          fill(255, 165, 0, 160);
          noStroke();
          drawShapeWithTris(objectLib[i].stylize(), panelPos, panelSize, color(0, 255, 255, 192), 1.5f);

          PVector com = objectLib[i].getCOM();
          stroke(0, 0, 255, 96);
          strokeWeight(1.5f);
          fill(255, 0, 0);
          circle(panelPos.x + com.x * panelSize.x, panelPos.y + com.y * panelSize.y, 3.5f);
        }
      }


      //drawing
      PVector drawPos = new PVector(width / 2f - height / 3f, height / 9f);
      PVector drawSize = new PVector(height * 2f / 3f, height * 2f / 3f);

      noFill();
      stroke(255, map(t, 0f, 1f, 255f, 0f));
      strokeWeight(6.66f);
      rect(drawPos.x + drawSize.x * t / 2f, drawPos.y + drawSize.y * t / 2f, drawSize.x * (1f - t), drawSize.y * (1f - t));

      if (currObj.vertices.size() > 0)
      {
        fill(255, 165, 0, map(t, 0f, 1f, 255f, 0f));
        noStroke();
        drawShape(currObj, drawPos, drawSize);

        //currObj.triangulate();
        //PVector com = currObj.getCOM();
        //if (com != null)
        //{
        //  stroke(0, 0, 255, 96);
        //  strokeWeight(1.5f);
        //  fill(255, 0, 0);        
        //  circle(drawPos.x + com.x * drawSize.x, drawPos.y + com.y * drawSize.y, 3.5f);
        //}

        noStroke();
        fill(255, 0, 0, map(t, 0f, 1f, 255f, 0f));      
        for (int i = 0; i < currObj.vertices.size(); i++)
        {
          circle(drawPos.x + currObj.vertices.get(i).x * drawSize.x, drawPos.y + currObj.vertices.get(i).y * drawSize.y, 15f);
        }
      }     


      //text
      fill(255, 255, 0);
      textSize(15);
      text("arrowkeys: switch windows", 0, map(t, 0f, 1f, 15f, -15f));
      text("press 0-9: save object to specific slot", 0, map(t, 0f, 1f, 30f, -30f));
      text("press 'd': discard current object", 0, map(t, 0f, 1f, 45f, -45f));
      text("press 'z': delete last vertex", 0, map(t, 0f, 1f, 60f, -60f));

      textSize(25);
      text("Object creation", (width - textWidth("Object creation")) / 2f, map(t, 0f, 1f, 35f, -35f));

      render = false;
    }
  }
  t = abs(window - 1f);
  if (t < 1f)
  {
    noStroke();
    fill(0, map(t, 0f, 1f, 255f, 0f));
    rect(0, 0, width, height);

    //water
    waterHeight = (1f - map(sin((1 - t) * HALF_PI * 1.35f), 0f, sin(HALF_PI * 1.35f), 0f, 1f) * .7f) * height;
    noStroke();
    fill(28, 163, 236, map(t, 0f, 1f, 255f, 64f));
    rect(0, waterHeight, width, height - waterHeight);

    //objPanel
    PVector panelSize = new PVector((height - (objectLib.length + 1) * 5f) / objectLib.length, (height - (objectLib.length + 1) * 5f) / objectLib.length);
    float objPanelWidth = map(t, 0f, 1f, width - panelSize.x - 10f, width + 5f);

    noStroke();
    fill(0, 128);
    rect(objPanelWidth, 0, panelSize.x + 10f, height);


    for (int i = 0; i < objectLib.length; i++)
    {
      PVector panelPos = new PVector(objPanelWidth + 5f, (i * height / objectLib.length + 5f) * (height - 5f) / height);

      noStroke();
      textSize(height / 15f);
      fill(255, 96);

      rect(panelPos.x, panelPos.y, panelSize.x, panelSize.y);
      text(i, objPanelWidth + height / 30f, panelPos.y + height / 15f + 5f);

      if (objectLib[i] != null)
      {
        fill(255, 165, 0, 160);
        noStroke();
        drawShapeWithTris(objectLib[i].stylize(), panelPos, panelSize, color(0, 255, 255, 192), 1f);

        PVector com = objectLib[i].centerOfMass;
        stroke(0, 0, 255, 96);
        strokeWeight(.75f);
        fill(255, 0, 0);
        circle(panelPos.x + com.x * panelSize.x, panelPos.y + com.y * panelSize.y, 3f);
      }
    }

    //text
    fill(255, 255, 0);
    textSize(15);
    text("arrowkeys: switch windows", 0, map(t, 0f, 1f, 15f, -15f));
    text("press 0-9: drop object in water", 0, map(t, 0f, 1f, 30f, -30f));
    text("press 'd': delete object(s) in water", 0, map(t, 0f, 1f, 45f, -45f));
    //text("press '': ", 0, map(t, 0f, 1f, 60f, -60f));

    textSize(25);
    text("Buoyancy simulation", (width - textWidth("Buoyancy simulation")) / 2f, map(t, 0f, 1f, 35f, -35f));
  }

  if (window == 1)
  {
    for (Object o : activeObjs)
    {
      o.update();
      drawShape(o, o.pos.copy().sub(o.centerOfMass.copy().mult(scale)), new PVector(scale, scale));
    }
  }
}

void mousePressed()
{
  if (window == 0)
  {
    if (insideBox(new PVector(mouseX, mouseY), new PVector(width / 2f - height / 3f, height / 9f), new PVector(width / 2f + height / 3f, height * 7f / 9f)))
    {
      PVector relativePos = new PVector(mouseX, mouseY).sub(new PVector(width / 2f - height / 3f, height / 9f)).div(height * 2f / 3f);   

      if (currObj.vertices.size() > 2)
      { 
        PVector prevEdge = currObj.getVert(currObj.vertices.size() - 1).copy().sub(currObj.getVert(currObj.vertices.size() - 2)).normalize();
        PVector potentialEdge = relativePos.copy().sub(currObj.getVert(currObj.vertices.size() - 1)).normalize();
        if (PVector.dot(prevEdge, potentialEdge) > .999f)//testing for colinear edges
        {
          return;
        }

        //test if the potential edge were going to intersect any other yet existing edges > if yes don't allow the vertex placement
        if (currObj.intersectEdges(currObj.getVert(currObj.vertices.size() - 1), relativePos).size() != 0)
        {
          return;
        }
      }
      currObj.vertices.add(relativePos);
      render = true;
    }
  }
}

void keyPressed()
{
  if (window == 0)
  {
    if (key == 'd')//discard currObj
    {
      currObj = new Object();
      render = true;
    } else if (key == 'z')//delete last vertex of currObj
    {
      if (currObj.vertices.size() > 0)
      {
        currObj.vertices.remove(currObj.vertices.size() - 1);
        render = true;
      }
    } else if (key - '0' >= 0 && key - '0' <= 9)
    {
      if (currObj.vertices.size() >= 3)
      {        
        if (currObj.crossingEdges())
        {
          return;
        }

        currObj.triangulate();
        objectLib[key - '0'] = currObj;
        currObj = new Object();
        render = true;
      }
    }
  } else if (window == 1)
  {
    if (key == 'd')
    {
      activeObjs.clear();
      render = true;
    } else if (key - '0' >= 0 && key - '0' <= 9)
    {
      if (objectLib[key - '0'] != null)
      {        
        activeObjs.add(objectLib[key - '0'].copy());

        activeObjs.get(activeObjs.size() - 1).getLowestPoint();
        activeObjs.get(activeObjs.size() - 1).pos = new PVector(mouseX, mouseY);
        activeObjs.get(activeObjs.size() - 1).vel = new PVector(0, 0);
      }
    }
  }
}

void drawShape(Object obj, PVector pos, PVector dimensions)
{
  beginShape();
  for (int i = 0; i < obj.vertices.size(); i++)
  {
    vertex(pos.x + obj.vertices.get(i).x * dimensions.x, pos.y + obj.vertices.get(i).y * dimensions.y);
  }
  endShape();
}

void drawShapeWithTris(Object obj, PVector pos, PVector dimensions, color tColor, float sWeight)
{
  drawShape(obj, pos, dimensions);

  if (obj.triangles != null && obj.triangles.length > 2)
  {
    stroke(tColor);  
    strokeWeight(sWeight);
    for (int i = 0; i < obj.triangles.length; i += 3)
    {
      float ax = pos.x + obj.vertices.get(obj.triangles[i + 0]).x * dimensions.x;
      float ay = pos.y + obj.vertices.get(obj.triangles[i + 0]).y * dimensions.y;
      float bx = pos.x + obj.vertices.get(obj.triangles[i + 1]).x * dimensions.x;
      float by = pos.y + obj.vertices.get(obj.triangles[i + 1]).y * dimensions.y;
      float cx = pos.x + obj.vertices.get(obj.triangles[i + 2]).x * dimensions.x;
      float cy = pos.y + obj.vertices.get(obj.triangles[i + 2]).y * dimensions.y;

      line(ax, ay, bx, by);
      line(bx, by, cx, cy);
      line(cx, cy, ax, ay);
    }
  }
}

float[] lineIntersect(PVector a1, PVector a2, PVector b1, PVector b2) //return t and u in a 2 element array
{
  float t = (a1.x - b1.x) * (b1.y - b2.y) - (a1.y - b1.y) * (b1.x - b2.x);  
  float u = (a1.x - b1.x) * (a1.y - a2.y) - (a1.y - b1.y) * (a1.x - a2.x);

  float b = (a1.x - a2.x) * (b1.y - b2.y) - (a1.y - a2.y) * (b1.x - b2.x);

  return new float[]{t / b, u / b};
}

void line(PVector a, PVector b)
{
  line(a.x, a.y, b.x, b.y);
}

float clamp(float input, float min, float max)
{
  return max(min(input, max), min);
}

boolean insideBox(PVector input, PVector tl, PVector br)
{
  return (input.x > tl.x && input.x < br.x) && (input.y > tl.y && input.y < br.y);
}

float cross2D(PVector a, PVector b)
{
  return a.x * b.y - a.y * b.x;
}

class Object
{
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  int[] triangles = null;

  //pysics
  PVector centerOfMass = null;
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  float lowPointFromCOM = 0;

  Object()
  {
  }

  Object(ArrayList<PVector> vertices)
  {
    this.vertices = new ArrayList<PVector>(vertices);
  }

  Object(ArrayList<PVector> vertices, int[] triangles)
  {
    this.vertices = new ArrayList<PVector>(vertices);
    this.triangles = triangles;
  }

  Object copy()
  {
    Object out = new Object();

    out.vertices = new ArrayList<PVector>(this.vertices);
    out.triangles = this.triangles;
    out.centerOfMass = this.centerOfMass.copy();
    out.pos = this.pos.copy();
    out.vel = this.vel.copy();
    out.lowPointFromCOM = this.lowPointFromCOM;

    return out;
  }

  Object stylize()
  {
    Object ret = new Object(this.vertices, this.triangles);    

    PVector center = new PVector(0, 0);    
    for (int i = 0; i < ret.vertices.size(); i++)
    {
      center.add(ret.vertices.get(i));
    }
    center.div(ret.vertices.size());
    PVector delta = new PVector(.5f, .5f).sub(center);

    for (int i = 0; i < ret.vertices.size(); i++)
    {
      float scale = 1f + delta.mag();
      ret.vertices.get(i).add(delta).div(scale).add(new PVector(.5f - .5f / scale, .5f - .5f / scale));
    }

    return ret;
  }


  //physics
  void update()
  {
    //only for test porpuses
    if (this.pos.y > waterHeight)
    {
      vel.add(gravity.copy().mult(-abs(this.getPolygonArea()) * scale * scale * .00001f));
    }

    vel.add(gravity.copy().div(frameRate));
    pos.add(vel.copy().div(frameRate).add(gravity.copy().div(2 * frameRate * frameRate)));

    if (lowPointFromCOM * scale + pos.y > height)
    {
      pos.y = height - lowPointFromCOM * scale;
      vel.y = 0;
    }
  }

  void getLowestPoint()
  {
    lowPointFromCOM = Float.NEGATIVE_INFINITY; 

    for (PVector v : vertices)
    {
      if (v.y - centerOfMass.y > lowPointFromCOM)
      {
        lowPointFromCOM = v.y - centerOfMass.y;
      }
    }
  }


  //center of mass calculations
  PVector getCOM()//get center of mass
  {    
    if (triangles == null)
    {
      return null;
    }
    if (triangles.length == 0)
    {
      return null;
    }

    PVector average = new PVector(0, 0);
    float weightSum = 0;  

    for (int i = 0; i < triangles.length; i += 3)
    {
      ArrayList<PVector> verts = new ArrayList<PVector>();      
      verts.add(getVert(triangles[i + 0]));
      verts.add(getVert(triangles[i + 1]));
      verts.add(getVert(triangles[i + 2]));

      PVector tcom = (verts.get(0).copy().add(verts.get(1).copy().add(verts.get(2)))).div(3f);

      Object temp = new Object(verts);
      float area = abs(temp.getPolygonArea());

      average.add(tcom.mult(area));
      weightSum += area;
    }

    centerOfMass = average.div(weightSum);

    return this.centerOfMass;
  }

  void rotAroundCOM(float angle)
  {
    if (centerOfMass == null)
    {
      return;
    }

    for (int i = 0; i < this.vertices.size(); i++)
    {
      this.vertices.get(i).sub(this.centerOfMass).rotate(angle).add(this.centerOfMass);
    }
  }


  //triangulate
  PVector getVert(int index)
  {
    return this.vertices.get(index % this.vertices.size() + (index < 0 ? this.vertices.size() : 0));
  }

  int getIndex(IntList list, int index)
  {
    return list.get(index % list.size() + (index < 0 ? list.size() : 0));
  }

  float getPolygonArea() //if area is negative it means the orientation of the vertices are anti-clockwise
  {
    float area = 0f;    
    for (int i = 0; i < vertices.size(); i++)
    {
      PVector curr = getVert(i);
      PVector next = getVert(i + 1);

      area += (next.x - curr.x) * (next.y + curr.y) / 2f;
    }

    return area;
  }

  boolean crossingEdges()
  {
    for (int i = 0; i <= vertices.size(); i++)
    {
      PVector a = getVert(i);
      PVector b = getVert(i + 1);

      for (int j = 0; j <= vertices.size(); j++)
      {
        if (i == j)
        {
          continue;
        }

        PVector c = getVert(j);
        PVector d = getVert(j + 1);

        float[] result = lineIntersect(a, b, c, d);
        if (result[0] > 0 && result[0] < 1 && result[1] > 0 && result[1] < 1)
        {
          return true;
        }
      }
    }

    return false;
  }

  FloatList intersectEdges(PVector a, PVector b)
  {
    FloatList intersections = new FloatList();

    for (int i = 0; i < vertices.size(); i++)
    {
      PVector c = getVert(i);
      PVector d = getVert(i + 1);

      float[] result = lineIntersect(a, b, c, d);
      if (result[0] > 0 && result[0] < 1 && result[1] > 0 && result[1] < 1)
      {
        intersections.append(result[0]);
        intersections.append(result[1]);
      }
    }

    return intersections;
  }

  boolean pointInTri(PVector p, PVector a, PVector b, PVector c)//only works if the points are in anti-clockwise order (a, b and c)
  {
    PVector ab = b.copy().sub(a);
    PVector bc = c.copy().sub(b);
    PVector ca = a.copy().sub(c);

    PVector ap = p.copy().sub(a);
    PVector bp = p.copy().sub(b);
    PVector cp = p.copy().sub(c);

    float cross1 = cross2D(ab, ap);
    float cross2 = cross2D(bc, bp);
    float cross3 = cross2D(ca, cp);

    return !(cross1 > 0f || cross2 > 0f || cross3 > 0f);
  }

  boolean triangulate() //only works if the vertecies are in anti-clockwise order
  {          
    if (vertices.size() < 3)
    {
      return false;
    }

    float area = getPolygonArea();
    if (area == 0)
    {
      return false;
    }
    if (area < 0)
    {
      Collections.reverse(vertices);
    }

    IntList indexList = new IntList();
    for (int i = 0; i < vertices.size(); i++)
    {
      indexList.append(i);
    }

    int currId = 0;
    triangles = new int[3 * (vertices.size() - 2)];

    while (indexList.size() > 3)
    {
      for (int i = 0; i < indexList.size(); i++)
      {
        int pi = getIndex(indexList, i - 1); //previous index
        int ci = indexList.get(i); //current index
        int ni = getIndex(indexList, i + 1); //next index

        PVector pv = vertices.get(pi); //previous vertex
        PVector cv = vertices.get(ci); //current vertex
        PVector nv = vertices.get(ni); //next vertex

        PVector ctp = pv.copy().sub(cv); //current to previous
        PVector ctn = nv.copy().sub(cv); //current to next

        //is ear test vertex convex?
        if (cross2D(ctp, ctn) < 0f)
        {
          continue;
        }

        boolean isEar = true;

        //does test ear contain any polygon vertices?
        for (int j = 0; j < vertices.size(); j++)
        {
          if (j == ci || j == pi || j == ni)
          {
            continue;
          }

          PVector p = vertices.get(j);

          if (pointInTri(p, pv, cv, nv))
          {
            isEar = false;
            break;
          }
        }

        if (isEar)
        {
          triangles[currId++] = pi;
          triangles[currId++] = ci;
          triangles[currId++] = ni;

          indexList.remove(i);
          break;
        }
      }
    }

    for (int i = 0; i < 3; i++)
    {
      triangles[currId + i] = indexList.get(i);
    }

    return true;
  }
}
