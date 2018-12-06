//code for digital installation - tweet4tree

import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;
import java.util.Calendar;
import ddf.minim.*;


////////////////////////////////////////////CONTROL VARIABLES////////////////////////////////////////////////////////////////

String searchString = "#TweetForTrees OR #Design4India OR #Embed2018"; ///search hashtags
String sinceTime = "2018-09-26"; /////////////////search since

color prim = color(125,204,237);//////////////////node's outer ring color
color[] sec = {color(255,255,62),color(176,255,62),color(255),color(6,255,251),color(130,244,236)};//,
color branch = color(216,199,0);
float dragPop = 30.0; ////////////////////////////control speed of pop
float popDia = 70.0;  ////////////////////////////control diameter of pop
float initDia = 5;
float nodeDiameter = 11.0;  /////////////////////control node's diameter
float nodeRadius = 25.0;  ///////////////////////control node's spread
float nodeStrength = -3;  ///////////////////////control node's strength


//Key Functions//

/*
(s) - save frame
(+) - increase diameter
(-) - decrease diameter
(p) - increase radius
(m) - decrease radius
(g) - increase repulsion
(w) - weaken repulsion
(u) - update all radius
(x) - add nodes manually
*/


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Twitter variables

Twitter twitter;
ArrayList<Status> tweets = new ArrayList<Status>();

Status status;
User usr;

int totalTweets = 0;

int tweetsPerQuery = 100;
long maxID = -1;
long sinceID = -1;

int currentTweet = 0;

int flagTweet = 0;
int addFlag = 0;




//canvas variables

Animation animL, animR;

int mode = 0;

float xpos;
float ypos;
float dx;
float dy;
float drag = 100.0;
int animFlag = 0;
int targetX, targetY;

int offX = -8;
int offY = 20;

PFont myFont;

int popFlag = 0;
float dr;


int nodeCount = 24; 


Node[] nodes = new Node[nodeCount];
IntList[] nodeCluster = new IntList[nodeCount];

Node bird = new Node();

Spring[] springs = new Spring[0];

int cluster = 0;
int index;
int counter = 0;

PImage bg;

Minim minim;
AudioSample audio;
int audioFlag = 0;

PImage webImg;
PGraphics mask;

void setup() {
  size(512, 640);
  //fullScreen();
  bg = loadImage("final-tree3.jpg");
  //bg = loadImage("tree_new.jpg");
 
  
  background(bg);
  smooth();
  noStroke();
  frameRate(60);
  initNodesAndSprings();
  
  for(int i = 0; i<nodeCount; i++){
    nodeCluster[i] = new IntList();
    nodeCluster[i].append(i);
    //println("intialised list for " + i);
  }
  //Twitter Bird Comp_00000
  animL = new Animation("finalL",45);
  animR = new Animation("finalR",45);
  
  minim = new Minim(this);
  audio = minim.loadSample("twitter_bird.mp3");
  
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("--");
  cb.setOAuthConsumerSecret("--");
  cb.setOAuthAccessToken("--");
  cb.setOAuthAccessTokenSecret("--");
  
  TwitterFactory tf = new TwitterFactory(cb.build());
  twitter = tf.getInstance();
  
  myFont = createFont("Gotham-Medium", 26);
  textFont(myFont);
  textAlign(LEFT,CENTER);
  textSize(26);
  
  saveFrame(timestamp()+"_##.png");
  thread("refreshTweets");
}


void draw() {

  imageMode(CENTER);
  background(bg);

  // let all nodes repel each other
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i].attract(nodes);
  } 
  // apply spring forces
  for (int i = 0 ; i < springs.length; i++) {
    springs[i].update();
  } 
  // apply velocity vector and update position
  for (int i = nodeCount ; i < nodes.length; i++) {
    nodes[i].update();
  } 
  
  if(popFlag == 1 && nodes.length > nodeCount){
    if(dr == nodes[nodes.length-1].tempDia - popDia) delay(1000);
    dr = nodes[nodes.length-1].tempDia - nodes[nodes.length-1].getDiameter();
    nodes[nodes.length-1].setDiameter(nodes[nodes.length-1].getDiameter() + dr/dragPop);
    if((int)dr == 0){
      popFlag = 0;
      
    }
  }
  
  if(counter<tweets.size() && popFlag == 0 && animFlag == 0){
    if(flagTweet==1){
      usr = tweets.get(tweets.size()-counter-1).getUser();
      //println(tweets.get(0).getText());
      addNodeSpring(usr.getOriginalProfileImageURLHttps());
    }
    else addNodeSpring(" ");
    
  }
    

////////////////drawing///////////////////////
  // draw springs
  
  stroke(branch);
  strokeWeight(1);
  for (int i = 0 ; i < springs.length; i++) {
    line(springs[i].fromNode.x, springs[i].fromNode.y, springs[i].toNode.x, springs[i].toNode.y);
  }
  
  // draw nodes
  noStroke();
  for (int i = 0 ; i < nodeCount; i++) {
    fill(nodes[i].getCol());
    ellipse(nodes[i].x, nodes[i].y, nodes[i].getDiameter(), nodes[i].getDiameter());
  }
  
  noStroke();
  int c;
  if(flagTweet==0)c = nodes.length;
  else c = nodes.length-1;
  for (int i = nodeCount; i < c; i++) {
    fill(nodes[i].getCol());
    ellipse(nodes[i].x, nodes[i].y, nodes[i].getDiameter(), nodes[i].getDiameter());
  }
  if(flagTweet==1){  
    if(popFlag==1){
      try{
        //webImg.resize((int)nodes[nodes.length-1].getDiameter(),(int)nodes[nodes.length-1].getDiameter());
        
        //println(webImg);
        mask = createGraphics(webImg.width, webImg.height);
        mask.beginDraw();
        mask.smooth();
        mask.background(0);
        mask.fill(255);
        //mask.fill(map(dr,nodes[nodes.length-1].tempDia-popDia,0,255,100));
        mask.ellipse(webImg.width/2, webImg.height/2, nodes[nodes.length-1].getDiameter(), nodes[nodes.length-1].getDiameter());
        mask.endDraw();
        webImg.mask(mask);
        imageMode(CENTER);
        image(webImg,nodes[nodes.length-1].x, nodes[nodes.length-1].y);
      }
      catch(Exception e){
        ellipse(nodes[nodes.length-1].x, nodes[nodes.length-1].y, nodes[nodes.length-1].getDiameter(), nodes[nodes.length-1].getDiameter());
        println(e);
      } 
    }
    else ellipse(nodes[nodes.length-1].x, nodes[nodes.length-1].y, nodes[nodes.length-1].getDiameter(), nodes[nodes.length-1].getDiameter());
  

  //display bird animation
  if(animFlag >0 && popFlag == 0){ 
    
    dx = targetX - xpos;
    dy = targetY - ypos;
    xpos = xpos + dx/drag;
    ypos = ypos + dy/drag;
    bird.x = xpos;
    bird.y = ypos;
    bird.setDiameter(25);
    bird.setStrength(-30);
    bird.setRadius(30);
    
    if(audioFlag == 0){
      audio.trigger();
      audioFlag = 1;
    }
    
    if(targetX<0)
      animL.display(xpos,ypos);
    else animR.display(xpos,ypos);
    bird.attract(nodes);
    if(xpos<-50||xpos>50+width){
      animFlag = 0;   
      audioFlag = 0;
      audio.stop();
      saveFrame(timestamp()+"_##.png");
      //audio.rewind();
    }
  }
  }

  //show number of tweets
  
  fill(color(255));
  if(counter<10000)text(nf(counter,4),21,29);//17,58
  else text(nf(counter,5),21,29);
}


void initNodesAndSprings() {
  // init nodes
  float rad;


  
  /////22 node counts//////
  
  nodes[0] = new Node(115+offX,237+offY);
  nodes[1] = new Node(141+offX,292+offY);
  nodes[2] = new Node(196+offX,337+offY);
  nodes[3] = new Node(187+offX,255+offY);
  nodes[4] = new Node(225+offX,283+offY);
  nodes[5] = new Node(336+offX,333+offY);
  nodes[6] = new Node(383+offX,328+offY);
  nodes[7] = new Node(357+offX,281+offY);
  nodes[8] = new Node(401+offX,254+offY);
  nodes[9] = new Node(406+offX,214+offY);
  nodes[10] = new Node(329+offX,219+offY);
  nodes[11] = new Node(370+offX,182+offY);
  nodes[12] = new Node(305+offX,170+offY);
  nodes[13] = new Node(247+offX,224+offY);
  nodes[14] = new Node(182+offX,211+offY);
  nodes[15] = new Node(230+offX,183+offY);
  nodes[16] = new Node(164+offX,144+offY);
  nodes[17] = new Node(214+offX,129+offY);
  nodes[18] = new Node(229+offX,97+offY);
  nodes[19] = new Node(227+offX,139+offY);
  nodes[20] = new Node(309+offX,120+offY);
  nodes[21] = new Node(371+offX,127+offY);
  nodes[22] = new Node(278+offX,139+offY);
  nodes[23] = new Node(291+offX,265+offY);
  
  
  
  
  for(int i = 0; i< nodeCount; i++){
    nodes[i].setDiameter(5); 
    rad = nodes[i].getDiameter()/2;
    nodes[i].setCol(branch);
    //if(random(5)>2)nodes[i].setCol(prim);
    //else nodes[i].setCol(sec);
    nodes[i].setBoundary(rad, rad, width-rad, height-rad);
    nodes[i].setRadius(nodeRadius);
    nodes[i].setStrength(nodeStrength);
    nodes[i].setID("cluster"+i);
  }
}

void addNodeSpring(String imgUrl){
  
  int clstr = (int)random(0,nodeCount);
  //int clustr = cluster;
  Node np = new Node(nodes[clstr].x+random(10,15), nodes[clstr].y+random(10,15));
  if(flagTweet==1)np.setDiameter(popDia);
  float rad = np.getDiameter()/2;
  np.setBoundary(rad, rad, width-rad, height-rad);
  np.setRadius(nodeRadius); //*random(0.8,1.5)
  np.setStrength(nodeStrength); //*random(0.7,1.5)
  np.setImg(imgUrl);
  np.setID("cluster"+clstr);
  
  np.setCol(sec[(int)random(0,sec.length)]);
  
  
  nodes = (Node[])append(nodes, np);
  nodeCluster[clstr].append(nodes.length-1);
  
  Spring ns;
  int nd = clstr;
  if(nodeCluster[clstr].size()>0 && random(5)>3.5){
    //for(int i = 0; i < nodeCluster[clstr].size(); i++) println(clstr,nodeCluster[clstr].get(i));
    nd = nodeCluster[clstr].get((int)random(0,nodeCluster[clstr].size()-1));
  }
  //println(nd,clstr);
  ns = new Spring(np,nodes[nd]);
  ns.setLength(3);
  ns.setStiffness(1);
  springs = (Spring[]) append(springs, ns);
  
  if(flagTweet==1){
    xpos = nodes[nodes.length-1].x;
    ypos = nodes[nodes.length-1].y;
    animFlag = 1;
    if(random(10)>5) targetX = -100;
    else  targetX = width+100;
    targetY = (int)random(-100,height/3);
    
    
    webImg = loadImage(nodes[nodes.length-1].getImg(), "png");
    webImg.resize((int)nodes[nodes.length-1].getDiameter(),(int)nodes[nodes.length-1].getDiameter());
    popFlag = 1;  

  }
  counter++;
  println(counter);
}


int getNewTweets(int f){
  int flagPast = f;
   try
    {
        
        Query query = new Query(searchString);
        query.setCount(tweetsPerQuery); // maximum number of tweets possible 
        query.setSince(sinceTime);
        //query.resultType(query.RECENT);
        query.setLang("en");
        
        if(maxID != -1 && flagPast == 0){
          query.setMaxId(maxID - 1);
          
        }
        else if(flagPast == 1){
          query.setMaxId(-1);
          query.setSinceId(sinceID);
        }
        
        QueryResult result = twitter.search(query);

        //tweets = result.getTweets();
        long id = -1;
        if(flagPast == 0){
          if(result.getTweets().size()>0){
            
            for(Status status: result.getTweets()){             
              if(id != status.getId()){
                id = status.getId();
                tweets.add(status);
                totalTweets++;
                //println("entered");
              }           
            }
            
            if(tweets.size()>0){
              maxID = tweets.get(tweets.size()-1).getId();
              sinceID = tweets.get(0).getId();
            }
          }
          else {
            flagPast = 1;         
          }
        }
        else{
          if(result.getTweets().size()>0){
            
           // for(Status status: result.getTweets()){
            for(int i = result.getTweets().size()-1; i > 0 ; i--){ 
              status = result.getTweets().get(i);
              if(id != status.getId() && id != sinceID){
                id = status.getId();
                tweets.add(0,status);
                totalTweets++;
              }
            }
            if(tweets.size()>0)sinceID = tweets.get(0).getId();
          }          
        }
    }
    catch (TwitterException te)
    {
        System.out.println("Failed to search tweets: " + te.getMessage());
        System.exit(-1);
    }

    return flagPast;
}

/*void rateLimit(){
  try
    {
      Map<String, RateLimitStatus> rateLimitStatus = twitter.getRateLimitStatus("search");
      RateLimitStatus searchTweetsRateLimit = rateLimitStatus.get("/search/tweets");
      System.out.printf("You have %d calls remaining out of %d, Limit resets in %d seconds\n",
                searchTweetsRateLimit.getRemaining(),
                searchTweetsRateLimit.getLimit(),
                searchTweetsRateLimit.getSecondsUntilReset());
    }
  catch (TwitterException te)
    {
        System.out.println("rateLimit exception " + te.getMessage());
        System.exit(-1);
    }
}*/

void refreshTweets()
{
    while (true)
    { 
      if(maxID == -1) flagTweet = 0;
      if(animFlag == 0 && popFlag == 0)flagTweet = getNewTweets(flagTweet);  
      //println(flagTweet);
      if(flagTweet == 1){
        println("Updated New Tweets,  tweets length: " + tweets.size());
        delay(10000);
      }
      else{
        println("Updated Old Tweets, New maxID " + maxID + " total: " + totalTweets + " tweets length: " + tweets.size());
        delay(10000);
      }
      
    }
}

void keyPressed() {
  if(key=='s') saveFrame(timestamp()+"_##.png"); 
  if(key=='u') {
    for(int i = nodeCount; i < nodes.length; i++){
      nodes[i].setDiameter(nodes[i].tempDia);
      nodes[i].update();
    }
    println("Diameter is reset");
  }
  if(key=='+') {
    for(int i = nodeCount; i < nodes.length; i++){
      nodes[i].setDiameter(nodes[i].getDiameter() + 2);
      nodes[i].update();
      //nodes[i].tempDia = nodes[i].tempDia + 2;     
    }
    nodeDiameter = nodeDiameter+2;
    println("Increased node diameter");
  }
  if(key=='-') {
    for(int i = nodeCount; i < nodes.length; i++){
      if(nodes[i].getDiameter()>2)nodes[i].setDiameter(nodes[i].getDiameter() - 2);
      nodes[i].update();
    }
    if(nodeDiameter>2)nodeDiameter = nodeDiameter-2;
    println("Decreased node diameter");
  }
  if(key=='p') {
    for(int i = 0; i < nodes.length; i++){
      nodes[i].setRadius(nodes[i].getRadius() + 5);
      nodes[i].update();
    }
    nodeRadius = nodeRadius + 5;
    println("Increased node radius");
  }
  if(key=='m') {
    for(int i = nodeCount; i < nodes.length; i++){
      if(nodes[i].getRadius()>10)nodes[i].setRadius(nodes[i].getRadius() - 5);
      nodes[i].update();      
    }
    if(nodeRadius>10)nodeRadius = nodeRadius - 5;
    println("Decreased node radius");
  }
  if(key=='g') {
    for(int i = nodeCount; i < nodes.length; i++){
      nodes[i].setStrength(nodes[i].getStrength() - 1);
      nodes[i].update();     
    }
     nodeStrength = nodeStrength - 1;    
     println("Increased node strength");
  }
  if(key=='w') {
    for(int i = nodeCount; i < nodes.length; i++){
      if(nodes[i].getStrength()<-1)nodes[i].setStrength(nodes[i].getStrength() + 1);
      nodes[i].update();
      }
      if(nodeStrength<-1)nodeStrength = nodeStrength + 1;
      println("Decreased node strength");
  }
  if(key == 'x'){
    tweets.add(tweets.get(0));
  }
}

void stop(){
  audio.close();
  minim.stop();
  super.stop();
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}
