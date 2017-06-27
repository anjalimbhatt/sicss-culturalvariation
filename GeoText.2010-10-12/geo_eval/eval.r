#######      R wrappers for the eval script

eval_2d_km = function(pred, real_lat, real_long) {
  real = data.frame(lat=real_lat, long=real_long)
  eval_full(real_lat=real_lat, real_long=real_long, pred_lat=pred$lat, pred_long=pred$long)
}

eval_full = function(real_lat,real_long, pred_lat, pred_long) {
  d = data.frame(real_lat,real_long, pred_lat, pred_long)
  write_nns(d,"/tmp/tmp.pred")
  system("python ../geo_eval/eval.py < /tmp/tmp.pred | tee /tmp/tmp.results | awk '/^--/{x=1} x'")
  invisible(load_eval_results("/tmp/tmp.results"))
}

load_eval_results = function(filename) {
  # col.names = "km loc1.admin1 loc2.admin1 region1 region2 div1 div2 metro1 metro2"
  col.names = "km state1 state2 region1 region2"
  col.names = strsplit(col.names, " ")[[1]]
  outcomes = read_nns(pipe(sprintf("cat %s | awk '/^--/{exit} 1'",filename)), col.names=col.names)
  list(outcomes=outcomes)
}

eval_center_guess = function(sp_lat, sp_long) {
  lat_ctr = mean(sp_lat$train$y)
  long_ctr= mean(sp_long$train$y)
  
  eval_full(real_lat=sp_lat$test$y, real_long=sp_long$test$y, pred_lat=lat_ctr, pred_long=long_ctr)
  # system("mv /tmp/tmp.results ../results/center_guess.log")
  # 
  # lat_dev =  sp_lat$test$y - lat_ctr
  # long_dev= sp_long$test$y - long_ctr
  # dists = sqrt(lat_dev**2 + long_dev**2)
  # list(
  #   avg_dist = mean(dists),
  #   med_dist = median(dists)
  #   )  
}

load_slda = function(filename) {
  # Oh so the way it works is, the last 2303 - 25 + 1 = 2279 lines are the
  #   output for the test set.  The format is
  # auth_id lat_guess lat_true long_guess long_true

  cmd = paste("cat",filename," | awk 'NF==5 && /^[0-9]/'")
  d = read.table(pipe(cmd),col.names=c('id','pred_lat','real_lat','pred_long','real_long'))
  # d = read.table(pipe(cmd),col.names=c('id','pred_long','real_long','pred_lat','real_lat'))
  d
}

eval_one_slda = function(slda_data) {
  with(slda_data, eval_full(real_lat=real_lat, real_long=real_long, pred_lat=pred_lat, pred_long=pred_long))
}

eval_all_slda = function() {
  for (k in c(1,5,10,20,30,40)) {
    print(k)
    d=load_slda(sprintf("../geoslda_201008_camera/runslda.test.%d.out",k))
    eval_one_slda(d)
    system(sprintf("mv /tmp/tmp.results ../results_201008_camera/test/slda.%d.eval",k))
  }
}
