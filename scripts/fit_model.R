library(rstan)
options(mc.cores = parallel::detectCores())

##########################
### Single Season Test ###
##########################

# make data
year <- 2020
stan_df <- schedules %>% filter(season == year,game_type == "REG",location == "Home")
stan_list <- 
  list(
    N_games = stan_df %>% nrow,
    N_teams = 32,
    home_team = stan_df %>% pull(home_team) %>% match(team_vars),
    away_team = stan_df %>% pull(away_team) %>% match(team_vars),
    score = stan_df %>% pull(home_result)
  )


# fit modeel
fit <- stan("scripts/season_model.stan",data = stan_list,iter = 2000,chains = 3,
            control = list(adapt_delta = 0.99),pars = c("score_mean","team_sigma_raw","alpha_raw"),include = FALSE)
fit

###########################
### Fit for all seasons ###
###########################

fits <- lapply(1999:2020,function(y){
  year <- y
  stan_df <- schedules %>% filter(season == year,game_type == "REG",location == "Home")
  stan_list <- 
    list(
      N_games = stan_df %>% nrow,
      N_teams = 32,
      home_team = stan_df %>% pull(home_team) %>% match(team_vars),
      away_team = stan_df %>% pull(away_team) %>% match(team_vars),
      score = stan_df %>% pull(home_result)
    )
  
  
  fit <- stan("scripts/season_model.stan",data = stan_list,iter = 2000,chains = 3,
              control = list(adapt_delta = 0.99),pars = c("score_mean"),include = FALSE)
  fit
})
save(team_vars,fits,file = "output/team_effects_default_priors.Rdata")
