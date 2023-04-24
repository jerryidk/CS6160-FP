

void test()
{
  println(" >>> Performance Test <<< ");
  performanceTest();
  
  println(" >>> Accuracy Test <<< ");
  accuracyTest();
}

void accuracyTest()
{

  
  int T_h = 10000; 
  int T_w = 10000;
  int iter = 50;
  
  for(int in=10; in <= 80; in *= 2) 
  {
    float score_bfs = 0.0;
    float score_manh = 0.0;
    float score_euc = 0.0;
    for(int i=0; i<iter; i++){
      Point s = new Point(1,1);
      Polygon robot = makeRobot(s);
      Point e = new Point(T_h-1, T_w-1);
      ArrayList<Polygon> o = makeRandomBoxesTest(in, T_w, T_h);
      VisibilityGraph g = new VisibilityGraph(robot, e, o);
      g.nodraw = true;
      g.solveall();
      score_bfs += g.scores.get("bfs");
      score_manh += g.scores.get("manh");
      score_euc += g.scores.get("euc");
    }
    
    println(" Input: ", in, "\n",
            " Iter: ", iter, "\n", 
            " Total BFS score: ", score_bfs, "\n",
            " Avg BFS score: ", (float) score_bfs/iter, "\n",
            " Total manh score: ", score_manh, "\n",
            " Avg manh score: ", (float) score_manh/iter, "\n",
            " Total euc score: ", score_euc, "\n",
            " Avg euc score: ", (float) score_euc/iter, "\n"
            );   
  }
  

}

// Module for testing performance of implementations
// works by testing may random sets of points
void performanceTest( ){
  
  
  ArrayList<String> methods = new ArrayList<String>();
  methods.add("bfs");
  methods.add("manh");
  methods.add("euc");
  
  int T_h = 10000; 
  int T_w = 10000;

  
  for(String method: methods) {
    int iter = 50;
    for(int in=10; in <= 80; in *= 2) 
    {
      int time = 0;
      for(int i=0; i<iter; i++){
        Point s = new Point(1,1);
        Polygon robot = makeRobot(s);
        Point e = new Point(T_h-1, T_w-1);
        ArrayList<Polygon> o = makeRandomBoxesTest(in, T_w, T_h);
        VisibilityGraph g = new VisibilityGraph(robot, e, o);
        g.nodraw = true;
        
        int start = millis();
        g.solve(method);
        int dt = millis()-start;
        time += dt;
      }
      
      println(" Method: ", method,
              " Input: ", in, 
              " Iter: ", iter, 
              " Time (ms): ", time);   
    }
  }
}
