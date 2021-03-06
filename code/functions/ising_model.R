ising_model <- function(prob, temp = 4) {
  
  # Dimensions of input matrix
  dimension <- nrow(prob)
  
  # Simulated Annealing Stopping Criterion
  SA.stop <- FALSE
  SA.update <- FALSE
  SA.updates <- 0
  
  # Holding matrices
  current.state <- matrix(1, nrow = dimension, ncol = dimension)
  prob <- prob
  current.state[which(prob < 0.25)] <- 0
  current.state[which(prob >= 0.25)] <- 0.5
  current.state[which(prob > 0.75)] <- 1
  
  
  # Defined Constant
  ln.alpha <- log(runif(1))
  energy.system <- sum(energy_system(current.state, dimension = dimension))
  
  while (SA.stop != TRUE) {
    
    temp.cur <- temp * (0.95 ^ SA.updates)
    SA.updates <- SA.updates + 1
    SA.update <- FALSE
    prob.previous <- prob
    SA.update.runs <- 0
    
    while (SA.update != TRUE) {
      
      SA.update.runs <- SA.update.runs + 1
      # Pick a random point and get its linear index
      row.index <- ceiling(dimension * runif(1))
      col.index <- ceiling(dimension * runif(1))
      lin.index <- (col.index - 1) * dimension + row.index 
      
      # Energy Change
      energy.cur <- energy(current.state, position = lin.index, 
                           value = current.state[lin.index],
                           dimension = dimension)
      energy.swap <- energy(current.state, position = lin.index, 
                            value = 1 - current.state[lin.index],
                            dimension = dimension)
      energy.change <- energy.swap - energy.cur
      
      # Metropolis Criterion                     
      if (energy.change <= 0) {
        current.state[lin.index] <- 1 - current.state[lin.index]
        
        # Update the temperature?
        if (abs(energy.change/energy.system) < 1) {
          SA.update <- TRUE
        }
      } else if (ln.alpha <= -energy.change/temp.cur) {
        current.state[lin.index] <- 1 - current.state[lin.index]
        
        # Update the temperature?
        if (abs(energy.change/energy.system) < 1) {
          SA.update <- TRUE
        }
      }
    }
    
    neigh.ones <- neigh_system(current.state, value = 1,
                               dimension = dimension)
    neigh.zeros <- neigh_system(current.state, value = 0,
                                dimension = dimension)

    prob.final.ones <- exp(neigh.ones)
    prob.final.zeros <- exp(neigh.zeros)
    prob <- prob.final.ones / (prob.final.ones + prob.final.zeros)
    
    # Are we finished annealing?
    if (max(abs(prob - prob.previous)) < 0.1 || SA.updates >= 43) {
      SA.stop <- TRUE
      prob.change <- max(abs(prob - prob.previous))
    }
  }
  
  neigh.ones <- neigh_system(current.state, value = 1,
                             dimension = dimension)
  neigh.zeros <- neigh_system(current.state, value = 0,
                              dimension = dimension)
  
  prob.final.ones <- exp(neigh.ones)
  prob.final.zeros <- exp(neigh.zeros)
  prob <- prob.final.ones / (prob.final.ones + prob.final.zeros)
  
  output <- structure(list(prob = prob, temperature = temp.cur, 
                           state = current.state, prob.change = prob.change))
  
  return(output)
}