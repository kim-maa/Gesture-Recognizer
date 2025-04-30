/**
* Gesture class that takes raw input from user, creates gesture, and can resample points
*/
class Gesture {
  ArrayList<Point> inputGesture;
  ArrayList<Point> resampledGesture;
  int startTime;
  
  /**
  * Create new gesture
  */
  public Gesture() {
    inputGesture = new ArrayList<Point>();
    resampledGesture = new ArrayList<Point>();
  }
  
  /**
  * Add a new Point for every point from input
  */
  public void addPoint(float x, float y, float t) {
    inputGesture.add(new Point(x, y, t));
  }
  
  /**
  * Visualize gesture input from user
  */
  public void drawGesture() {
    stroke(0, 0, 255);
    noFill();
    beginShape();
    for (Point p : inputGesture) {
      vertex(p.x, p.y);
    }
    endShape();
  
    // circles to help visualize fast and slow points
    fill(0, 0, 255);
    noStroke();
    for (Point p : inputGesture) {
      ellipse(p.x, p.y, 6, 6);
    }
  }

  
  /**
  * Resample the gesture to create 64 new points that are equally spaced along the length of the gesture
  */
  public void resamplePoints() {
    int targetPoints = 64;
    float step = totalGestureLength() / (targetPoints - 1);
    ArrayList<Point> newGesture = new ArrayList<>();
    newGesture.add(inputGesture.get(0));

    float currentDistance = 0;
    int originalIndex = 1;

    for (int i = 1; i < targetPoints - 1; i++) {
        float targetDistance = i * step;
        
        // go through gesture until the total current distance plus the next interval is at least the targetDistance
        while (originalIndex < inputGesture.size() && currentDistance + dist(inputGesture.get(originalIndex - 1).x,
               inputGesture.get(originalIndex - 1).y, inputGesture.get(originalIndex).x,
               inputGesture.get(originalIndex).y) < targetDistance) {
            
            // add current interval distance to the total
            currentDistance += dist(inputGesture.get(originalIndex - 1).x, inputGesture.get(originalIndex - 1).y, inputGesture.get(originalIndex).x, inputGesture.get(originalIndex).y);
            originalIndex++;
        }

        // if out of bounds, break
        if (originalIndex >= inputGesture.size()) break;

        Point p1 = inputGesture.get(originalIndex - 1);
        Point p2 = inputGesture.get(originalIndex);

        // correct interval for new point found between the two original points,
        // then find ratio of that interval where the new point wil be
        float remainingDistance = targetDistance - currentDistance;
        float interval = dist(p1.x, p1.y, p2.x, p2.y);
        float ratio = remainingDistance / interval;

        // built-in interpolate function
        float interpX = lerp(p1.x, p2.x, ratio);
        float interpY = lerp(p1.y, p2.y, ratio);
        float interpT = lerp(p1.t, p2.t, ratio);

        newGesture.add(new Point(interpX, interpY, interpT));
    }

    newGesture.add(inputGesture.get(inputGesture.size() - 1));
    resampledGesture = newGesture;
    
    // normalize time so the first value in the gesture is 0, and the final is 1
    float resampledStartTime = resampledGesture.get(0).t;
    float resampledEndTime = resampledGesture.get(resampledGesture.size() - 1).t;
    for (Point p : resampledGesture) {
      p.t = map(p.t, resampledStartTime, resampledEndTime, 0, 1);
    }
}

  /**
  * Calculate the total distance length of the gesture
  */
  public float totalGestureLength() {
    float length = 0;
    for (int i = 1; i < inputGesture.size(); i++) {
      Point curPoint = inputGesture.get(i - 1);
      Point nextPoint = inputGesture.get(i);
      length += dist(curPoint.x, curPoint.y, nextPoint.x, nextPoint.y);
    }
    
    return length;
  }
  
  /**
  * Visualize the time data for the gesture in a 300x300-pixel square
  */
  public void drawResampledInputGesture(float translateX, float translateY, float size) {
    stroke(0);
    noFill();
    rect(translateX, translateY, size, size);
    
    // move grid by translating
    pushMatrix();
    translate(translateX, translateY);
    
    stroke(255, 0, 0);
    noFill();
    beginShape();
    
    // using home coords, x and y will range from 0 to size
    for (int i = 0; i < resampledGesture.size(); i++) {
      float x1 = map(i, 0, resampledGesture.size() - 1, 0, size);
      float y1 = map(resampledGesture.get(i).t, 0, 1, size, 0);
      vertex(x1, y1);
    }
    
    endShape();
    popMatrix();
  }

  
  /**
  * Compare this gesture to another gesture g by grabbing the absolute differences between normalized time values.
  */
  public float compare(Gesture gesture) {
    float error = 0;
    for (int i = 0; i < 64; i++) {
      error += abs(this.resampledGesture.get(i).t - gesture.resampledGesture.get(i).t);
    }
    
    return error;
  }
}
