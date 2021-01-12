

data{
  int<lower=1> N_games; // number of games
  int<lower=1> N_teams; // number of teams
  int<lower=1,upper=N_teams> home_team[N_games]; // home team ID
  int<lower=1,upper=N_teams> away_team[N_games]; // away team ID
  
  vector[N_games] score; // home point differential
}

parameters{
  // hierarchical parameters
  real alpha_mean;
  real<lower=0> alpha_sigma;
  
  // team skill variance
  real<lower=0> mu_sigma;
  
  // observation variance
  real<lower=0> score_sigma;
  
  // HFA and skill vectors
  vector[N_teams] alpha_raw;
  vector[N_teams] mu;
}

transformed parameters{
  vector[N_teams] alpha;
  // centered parameterization helps mixing of alpha_sigma a lot
  alpha = alpha_mean + alpha_raw*alpha_sigma;

}

model{
  vector[N_games] score_mean;
  score_mean = alpha[home_team] + mu[home_team] - mu[away_team]; //mean for each game
  
  //currently using STAN default priors, uncomment to change
  //alpha_mean ~ normal(0,10);
  //alpha_sigma ~ normal(0,10);
  alpha_raw ~ std_normal();
  

  //mu_sigma ~ normal(0,10);
  mu ~ normal(0,mu_sigma);
  
  score ~ normal(score_mean,score_sigma);
}