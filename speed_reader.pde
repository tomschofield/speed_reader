// import gab.opencv.*;
// import processing.video.*;
import java.awt.*;

// Capture video;
// OpenCV opencv;


String [] words;
String [][] c_words;
Chapter [] chapters;
float wpm = 250;
float wordInterval;
float chapterInterval;
boolean displayTitle = true;
long startTime = 0;

long chapterStartTime=0;

int wordIndex = 0;
PFont font;
PFont titleFont;
boolean go =false;
XML xml;
int chapter_count = 0;
int useCamera = 1;
int fontSize;
int titleFontSize;

void setup() {
  //println(PFont.list() );
  xml = loadXML("settings.xml");
  //XML[] children = xml.getChildren("settings");
  int cameraId = xml.getChild("cameraID").getIntContent();
  int sW = xml.getChild("screenWidth").getIntContent();
  int sH = xml.getChild("screenHeight").getIntContent();
  fontSize = xml.getChild("fontSize").getIntContent();
  titleFontSize = xml.getChild("titleFontSize").getIntContent();
  wpm = xml.getChild("wpm").getIntContent();
  int titleWpm = xml.getChild("titleWpm").getIntContent();
  String fontName = xml.getChild("fontName").getString("name");
  useCamera= xml.getChild("useCamera").getIntContent();

  //println("cameraId ", cameraId);
  //println("fontName ", fontName);
  //println("fontSize ", fontSize);
  
  //char[] charset = { '–','Ž', '+','=', '“','”',   '\\','|','-','_',    '~','`', ',','.','?', '/',';',':','"','\'',   '1','2','3','4','5','6','7','8','9','0', 'A','B','C','D', 'E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','X','!','@','£','$','%','^','&','*','(','É','I','L','E', '>', 'o', '\u2600', '\u2605' };
  
  char [] charset =  new char[255];
  for(int i=0;i<charset.length;i++){
   charset[i] = (char) i; 
  }
  font = createFont(fontName, fontSize, true, charset);
  titleFont = createFont(fontName, titleFontSize);

  textFont(font);
  String lines [] = loadStrings("final.txt");
  String wholeText = join(lines, " ");
  for(int i=0;i<wholeText.length();i++){
   
   if((int) wholeText.charAt(i)>255){
     println( wholeText.charAt(i)); 
   }
  }
  
  ////println(wholeText);
  size(sW, sH, P2D);
  words = splitTokens(wholeText, " ");

  wordInterval = 60000 /wpm;
  chapterInterval = 60000 / titleWpm;
  
  if (useCamera==1) {
    //println("using camera"); 
    // video = new Capture(this, 640/2, 480/2);
    // opencv = new OpenCV(this, 640/2, 480/2);
    // opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

    // video.start();
  } else {
    //println("no camera");
    go =true;
  }
  //textAlign(CENTER);
//  getChapterTitles(words);
//  c_words = getChapters(words);
  chapters = getAllChapters(words);

  words =  chapters[chapter_count].words;  //c_words[chapter_count];
  chapter_count++;
}


void draw() {
  background(0, 0, 0);
  fill(255);
  if (useCamera==1) {
    // opencv.loadImage(video);
    // Rectangle[] faces = opencv.detect();
    //println(faces.length);
    //float offset = getCentralCharPos(trim(words[wordIndex]));
    // if (faces.length>0) {
    //   go=true;
    // } else {
    //   go=false;
    // }
  }

  String thisWord="";
  ////println("thisWord", words[wordIndex], words.length, wordIndex);
  if (wordIndex>=words.length) {
    wordIndex = 0;
    //println("NOW DISPLAYING CHAPTER ", chapter_count);

    words = chapters[chapter_count].words;
    chapter_count++;
    chapterStartTime=millis();
    displayTitle = true;
    if (chapter_count>=chapters.length) {
      chapter_count=0;
    }
  }
  if (words[wordIndex]!=null) {

    thisWord = trim(words[wordIndex]);


    int centralCharIndex = getCentralCharIndex(thisWord);
    String centralChar = getCentralChar(thisWord);

    float offset = 0;
    for (int i=0; i<centralCharIndex; i++) {
      offset+=textWidth(str(thisWord.charAt(i)));
    }
    if (thisWord.length()>1) {
      offset+= 0.5 *(textWidth(str(thisWord.charAt(centralCharIndex))));
    }
    if (!displayTitle) {
      textFont(font);
      translate( (width/2)-offset, height/2);
      fill(0, 255, 0);

      float xPos = 0;


      for (int i=0; i<thisWord.length (); i++) {
        if (i==getCentralCharIndex(thisWord)) {
          fill(255, 0, 0);
        } else {
          fill(255);
        }
        text(str(thisWord.charAt(i)), xPos, 0     );

        xPos+=textWidth(str(thisWord.charAt(i)));
      }
    } else {
      textFont(titleFont);
      //      //println("displayingtitle");
      //       //println( join(chapters[chapter_count].titles, "\n"));
      for (int i=0; i<chapters[chapter_count].titles.length; i++) {
        pushMatrix();
        String title = chapters[chapter_count].titles[i];//join(chapters[chapter_count].titles, "\n");
        offset = textWidth(title)/2;
        float yOffset =(( chapters[chapter_count].titles.length * titleFontSize )/2) ; 
        translate( (width/2)-offset,( (height/2)-yOffset)+(i*titleFontSize));
        text(title, 0, 0);
        popMatrix();
      }
    }

    //have condition for title here
    if (millis()-chapterInterval>=chapterStartTime) {
      displayTitle=false;
    }  
    if (!displayTitle) {
      if (millis()-wordInterval>=startTime) {
        startTime=millis();
        if (go) {
          wordIndex++;
        }
      }
    }
  } else {
    wordIndex++;
  }
}
float getCentralCharPos(String word) {

  int numChars = word.length();
  int centralCharIndex =int( numChars/2.0);
  float fCentralCharIndex = numChars/2.0;
  float centralCharPos = 0.0;
  String centralChar="";


  if (numChars>2) {
    if (fCentralCharIndex - centralCharIndex>0) {

      centralChar = str( word.charAt(centralCharIndex)  );
    } else {
      centralChar = str( word.charAt(centralCharIndex)  );
    }
  } else {
    centralChar =  str( word.charAt(0)  );
    centralCharIndex = 0;
  }
  ////println("centralChar ", centralChar, " of ", word, " length is ", numChars );
  //  for(int i=0;i<numChars;i++){
  //   ////println("char at ",i," is ",word.charAt(i)); 
  //  }
  String sub = word.substring(centralCharIndex);
  float sWidth = textWidth(sub);
  return sWidth;
}
String getCentralChar(String word) {

  int numChars = word.length();
  int centralCharIndex =int( numChars/2.0);
  float fCentralCharIndex = numChars/2.0;
  float centralCharPos = 0.0;
  String centralChar="";


  if (numChars>2) {
    if (fCentralCharIndex - centralCharIndex>0) {

      centralChar = str( word.charAt(centralCharIndex)  );
    } else {
      centralChar = str( word.charAt(centralCharIndex)  );
    }
  } else {
    centralChar =  str( word.charAt(0)  );
    centralCharIndex = 0;
  }
  ////println("centralChar ", centralChar, " of ", word, " length is ", numChars );
  //  for(int i=0;i<numChars;i++){
  //   ////println("char at ",i," is ",word.charAt(i)); 
  //  }
  String sub = word.substring(centralCharIndex);
  float sWidth = textWidth(sub);
  return centralChar;
}
int getCentralCharIndex(String word) {

  int numChars = word.length();
  int centralCharIndex =int( numChars/2.0);
  float fCentralCharIndex = numChars/2.0;
  float centralCharPos = 0.0;
  String centralChar="";


  if (numChars>2) {
    if (fCentralCharIndex - centralCharIndex>0) {
      //centralCharIndex++;
      centralChar = str( word.charAt(centralCharIndex)  );
    } else {
      centralChar = str( word.charAt(centralCharIndex)  );
    }
  } else {
    centralChar =  str( word.charAt(0)  );
    centralCharIndex = 1;
  }
  ////println("centralChar ", centralChar, " of ", word, " length is ", numChars );
  //  for(int i=0;i<numChars;i++){
  //   ////println("char at ",i," is ",word.charAt(i)); 
  //  }
  String sub = word.substring(centralCharIndex);
  float sWidth = textWidth(sub);
  return centralCharIndex;
}
// void captureEvent(Capture c) {
//   c.read();
// }

void checkIsChapterTitle() {
}
String [] getChapterTitles(String[] words) {
  ArrayList <String >titles = new ArrayList<String>();

  for (int i=0; i<words.length; i++) {
    if (words[i].length()>=2) {
      if (words[i].charAt(0) == '*' && words[i].charAt(1)== '*') {
        // //println(words[i]);
        boolean foundEnd = false;
        int index = 0;
        String title="";
        //keep looking till we've found the end of the title
        while (!foundEnd) {
          if (i+index<words.length) {
            if (words[i+index].charAt(words[i+index].length()-1)=='*') {
              title+=words[i+index];
              title+=" ";
              foundEnd= true;
              //println(title);
              titles.add(title);
            } else {
              title+=words[i+index];
              title+=" ";
            }


            index++;
          }
        }
      }
    }
  }
  String [] arr_titles = titles.toArray(new String [titles.size()]);
  return arr_titles;
}

String [][] getChapters(String[] words) {
  ArrayList <String >chapters = new ArrayList<String>();
  String chapter = "";
  boolean isTitle = false;
  boolean isLastWordofTitle = false;

  for (int i=0; i<words.length; i++) {
    if (words[i].length()>=2) {
      if (words[i].charAt(0) == '*' && words[i].charAt(1)== '*') {
        isTitle=true;
        chapters.add(chapter);
        chapter = "";
      }

      if (words[i].charAt(words[i].length()-1)=='*') {
        isLastWordofTitle=true;
        isTitle=false;
      }
    }

    if (!isTitle && !isLastWordofTitle) {
      chapter+=words[i];
      chapter+=" ";
    }
    isLastWordofTitle=false;
  }
  String [] arr_chapters = chapters.toArray(new String [chapters.size()]);

  //println(arr_chapters.length);
  int real_chapter_count = 0;
  for (int i=0; i<arr_chapters.length; i++) {
    if (splitTokens(arr_chapters[i], " ").length>0) {
      real_chapter_count++;
    }
  }
  String [][] chapter_words = new String[real_chapter_count][];
  int index = 0;
  for (int i=0; i<arr_chapters.length; i++) {
    ////println(arr_chapters[i]);
    if (splitTokens(arr_chapters[i], " ").length>0) {
      PrintWriter output;
      output = createWriter("text/"+str(i)+".txt");
      output.println(arr_chapters[i]);
      output.flush();
      output.close();
      chapter_words[index] = splitTokens(arr_chapters[i], " ");
      index++;
    }
  }

  for (int i=0; i<chapter_words.length; i++) {
    ////println(arr_chapters[i]);
    //println(chapter_words[i].length);
  }
  //  
  return chapter_words;
}

Chapter[] getAllChapters(String[] words) {
  ArrayList <Chapter>chapters = new ArrayList<Chapter>();
  boolean isTitle = false;
  int startIndex = 0;
  int endIndex = 0;
  ArrayList <String> title_words = new ArrayList<String>();
  
  
  String [] hack_title = loadStrings("title.txt");
  String [] hack_chapter = loadStrings("first.txt");
  
  String hackText = join(hack_chapter, " ");
  
  Chapter hack = new Chapter(splitTokens(hackText," " ),hack_title);
   chapters.add(hack);
  String aTitle = "";

  for (int i=0; i<words.length; i++) {
    //gather chapter titles

    //boolean 
    if (words[i].length()>=2) {
      if (words[i].charAt(0) == '*' && words[i].charAt(1)== '*') {
        isTitle=true;
        startIndex = i; 
        int distance_since_last_title_end =  i-endIndex;
        //if this was just another title, then do nothign
        if (distance_since_last_title_end<3) {
        } 
        //if this was the text
        else {

          String [] chapter_words = new String[distance_since_last_title_end];
          int count = 0;
          for (int j=endIndex+1; j<i; j++) {
            if (words[j]!=null) {
              chapter_words[count] = words[j];
              count++;
            }
          }
          // //println("new chapter at ", i, " last star was at ", endIndex, words[i], " last word ", words[endIndex], " distance ", distance_since_last_title_end);

          Chapter aChapter = new Chapter(chapter_words, title_words.toArray(new String [title_words.size()]));
          chapters.add(aChapter);
          title_words= new ArrayList<String>();
        }
        //if it was the text then make this the text for the chapter, add the titles and add the whole thing to a list
      }
      if (words[i].charAt(words[i].length()-1)=='*') {
        isTitle = false;
        endIndex = i;
        aTitle+=words[i];
        title_words.add(aTitle);
        aTitle="";

        //isTitle=false; c

        //now lets check if the next word is
      }
    }
    if (isTitle) {
      aTitle+=words[i];
      aTitle+=" ";
    }

    //then gather chapter text
    //
  }
  Chapter [] arr_chapters = new Chapter[chapters.size()];
  for (int i=0; i<chapters.size (); i++) {
    arr_chapters[i] = (Chapter) chapters.get(i);
  }
  //println("arr_chapters.length ", arr_chapters.length);
  for (int i=0; i<arr_chapters.length; i++) {

    for (int j=0; j<arr_chapters[i].titles.length; j++) {
      if (arr_chapters[i].titles[j].length()>3) {
        arr_chapters[i].titles[j] = arr_chapters[i].titles[j].replace("*", "");     //substring(2,arr_chapters[i].titles[j].length()-1 );
      }

      //check for null characters
      int goodCount = 0;
    }
    //println("//////////////////////////////////////chapter at ", i);
    //println(join(arr_chapters[i].titles, "\n"));
    //println("chapter text//////////////////////////////////////", i);
    //println(join(arr_chapters[i].words, " "));
  }
  
  for(int i=0;i<arr_chapters.length-1;i++){
    arr_chapters[i].words=arr_chapters[i+1].words;
  }
  return arr_chapters;
}

String [][] getChapterObjects(String[] words) {
  ArrayList <Chapter >chapters = new ArrayList<Chapter>();
  String chapter = "";
  boolean isTitle = false;
  boolean isLastWordofTitle = false;

  for (int i=0; i<words.length; i++) {
    if (words[i].length()>=2) {
      if (words[i].charAt(0) == '*' && words[i].charAt(1)== '*') {
        isTitle=true;

        Chapter new_chapter = new Chapter();
        new_chapter.paragraph = chapter;
        //println("adding chapers");
        chapters.add(new_chapter);
        chapter = "";
      }

      if (words[i].charAt(words[i].length()-1)=='*') {
        isLastWordofTitle=true;
        isTitle=false;
      }
    }

    if (!isTitle && !isLastWordofTitle) {
      chapter+=words[i];
      chapter+=" ";
    }
    isLastWordofTitle=false;
  }
  String [] arr_chapters = chapters.toArray(new String [chapters.size()]);

  //println(arr_chapters.length);
  int real_chapter_count = 0;
  for (int i=0; i<arr_chapters.length; i++) {
    if (splitTokens(arr_chapters[i], " ").length>0) {
      real_chapter_count++;
    }
  }
  String [][] chapter_words = new String[real_chapter_count][];
  int index = 0;
  for (int i=0; i<arr_chapters.length; i++) {
    ////println(arr_chapters[i]);
    if (splitTokens(arr_chapters[i], " ").length>0) {
      PrintWriter output;
      output = createWriter("text/"+str(i)+".txt");
      output.println(arr_chapters[i]);
      output.flush();
      output.close();
      chapter_words[index] = splitTokens(arr_chapters[i], " ");
      index++;
    }
  }

  for (int i=0; i<chapter_words.length; i++) {
    ////println(arr_chapters[i]);
    // //println(chapter_words[i].length);
  }
  //  
  return chapter_words;
}
