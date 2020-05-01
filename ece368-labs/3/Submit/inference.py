import numpy as np
import graphics
import rover


def forward_backward(all_possible_hidden_states,
                     all_possible_observed_states,
                     prior_distribution,
                     transition_model,
                     observation_model,
                     observations):
    """
    Inputs
    ------
    all_possible_hidden_states: a list of possible hidden states
    all_possible_observed_states: a list of possible observed states
    prior_distribution: a distribution over states

    transition_model: a function that takes a hidden state and returns a
        Distribution for the next state
    observation_model: a function that takes a hidden state and returns a
        Distribution for the observation from that hidden state
    observations: a list of observations, one per hidden state
        (a missing observation is encoded as None)

    Output
    ------
    A list of marginal distributions at each time step; each distribution
    should be encoded as a Distribution (see the Distribution class in
    rover.py), and the i-th Distribution should correspond to time
    step i
    """

    num_time_steps = len(observations)
    
    
    ########################################################################
    ################ Compute the forward messages ##########################
    ########################################################################
    print("Computing forward messages")
    """ Initialization """
    forward_messages = [None] * num_time_steps
    
    forward_messages[0] = rover.Distribution()
    for state in all_possible_hidden_states:
        forward_messages[0][state] = prior_distribution[state] * ( observation_model(state) )[observations[0]]
    
    """ 
    Perform computation:
    fm[n] = p((xn, yn) | zn) * sum_over_zn-1{ fm[n-1] * p(zn | zn-1) } 
    """
    for time_step in range(1, num_time_steps):
        print("-", end = '')
        curr = rover.Distribution()
        prev = forward_messages[time_step - 1]
        
        """ Fill in the distribution """
        for curr_state in all_possible_hidden_states:
            """ Sum over previous time_step """
            for prev_state in all_possible_hidden_states:
                if(observations[time_step] != None):
                    curr[curr_state] += prev[prev_state] * ( transition_model(prev_state) )[curr_state] * ( observation_model(curr_state) )[observations[time_step]]
                else:
                    curr[curr_state] += prev[prev_state] * ( transition_model(prev_state) )[curr_state] * 1.0
        
        """ Normalize this distribution """
        curr.renormalize()
        
        """ Store distribution into forward_messages """
        forward_messages[time_step] = curr
    
    print(" ")
    
        
    ########################################################    
    ########### Compute the backward messages ##############
    ########################################################
    print("Computing backward messages")
    """ Initialization """
    backward_messages = [None] * num_time_steps    
    
    backward_messages[num_time_steps - 1] = rover.Distribution()
    for state in all_possible_hidden_states:
        backward_messages[num_time_steps - 1][state] = 1.0
    
    """ Iterate through  """
    for time_step in range(num_time_steps-2, -1, -1):
        print("-", end = '')
        prev = rover.Distribution()
        curr = backward_messages[time_step + 1]
        
        """ Iterate over zn-1 """
        for prev_state in all_possible_hidden_states:
            for curr_state in all_possible_hidden_states:
                if(observations[time_step+1] != None):
                    prev[prev_state] += curr[curr_state] * ( observation_model(curr_state) )[observations[time_step+1]] * ( transition_model(prev_state) )[curr_state] 
                else:
                    prev[prev_state] += curr[curr_state] * 1.0 * ( transition_model(prev_state) )[curr_state] 
                    
        """ Normalize new distribution """
        prev.renormalize()
        
        """ Store distribution in backward_messages """
        backward_messages[time_step] = prev
    
    print(" ")
        
    
    ##############################################
    ########### Compute the marginals ############
    ##############################################       
    print("Computing marginals")
    
    marginals = [None] * num_time_steps     
    
    """ Compute the rest of the marginals """
    for time_step in range(0, num_time_steps):
        marginals[time_step] = rover.Distribution()
        for state in all_possible_hidden_states:
            marginals[time_step][state] = forward_messages[time_step][state] * backward_messages[time_step][state]
        marginals[time_step].renormalize()
     
    return marginals



"""
Helper functions for Viterbi
"""
def log(x):
    if x == 0:
        return -np.inf
    else:
        return np.log(x)

def maxstate(x, all_possible_hidden_states):
    maxstate = None
    
    for state in all_possible_hidden_states:
        if(maxstate == None):
            maxstate = state
        elif(x[state] > x[maxstate]):
            maxstate = state
            
    return maxstate         

def Viterbi(all_possible_hidden_states,
            all_possible_observed_states,
            prior_distribution,
            transition_model,
            observation_model,
            observations):
    """
    Inputs
    ------
    See the list inputs for the function forward_backward() above.

    Output
    ------
    A list of estimated hidden states, each state is encoded as a tuple
    (<x>, <y>, <action>)
    """
    num_time_steps = len(observations)
    estimated_hidden_states = [None] * num_time_steps
    
    """ Create vector of functions. These functions will be implemented as distributions """
    W = [None] * num_time_steps
    B = [None] * num_time_steps
    
    W[0] = rover.Distribution()
    for state in all_possible_hidden_states:
        if(observations[0] != None):
            W[0][state] = log(prior_distribution[state]) + log( ( observation_model(state) )[observations[0]] )
        else:
            W[0][state] = log(prior_distribution[state]) + 0.0
    B[0] = None
    
    """ First pass through. Construct all the w equations. """
    for time_step in range(1, num_time_steps):
        print("-", end='')
        W[time_step] = rover.Distribution() 
        back_dist = rover.Distribution()
        
        for curr in all_possible_hidden_states:
            max_state = None
            max_value = -np.inf
            for prev in all_possible_hidden_states:
                new_value = log( ( transition_model(prev) )[curr] ) + W[time_step-1][prev]
                if(new_value > max_value):
                    max_value = new_value
                    max_state = prev
            
            if(observations[time_step] != None):
                W[time_step][curr] = log( (observation_model(curr))[observations[time_step]] ) + max_value
            else:
                W[time_step][curr] = max_value
            
            back_dist[curr] = max_state
        
        B[time_step] = back_dist
                
    print(" ")
    
    
    best_path_ptr = all_possible_hidden_states[0]
    for state in all_possible_hidden_states:
        if(W[num_time_steps-1][state] > W[num_time_steps-1][best_path_ptr]):
            best_path_ptr = state
            
    estimated_hidden_states[num_time_steps-1] = best_path_ptr
    
    best_path_ptr = B[num_time_steps-1][best_path_ptr]
    
    for time_step in range(num_time_steps-2, -1, -1):
        estimated_hidden_states[time_step] = best_path_ptr
        if(time_step == 0):
            break
        else:
            temp = best_path_ptr
            best_path_ptr = B[time_step][temp] 
    
    
    
#    """ Second pass through, compute and record the argmax's """
#    for time_step in range(0, num_time_steps):
#        max_state = all_possible_hidden_states[0]
#        for state in all_possible_hidden_states:
#            if(W[time_step][state] > W[time_step][max_state]):
#                max_state = state
#        estimated_hidden_states[time_step] = max_state
    
    return estimated_hidden_states
    
    
####################################################################################################
####################################################################################################
"""
Compute the error
"""
def compute_forward_backward_error(marginals, hidden_states, all_possible_hidden_states):
    count=0
    for i in range(0, len(hidden_states)):
        argmax = maxstate(marginals[i], all_possible_hidden_states)
        (estx, esty, act) = argmax
        (hx, hy, acth) = hidden_states[i]
        if(estx == hx and esty == hy):
            count+=1
        else:
            print(i, hidden_states[i], argmax)
    print("Number of correct estimations by forward backward:")
    print(count)
    print("Total estimations:")
    print(len(hidden_states))
    print(" ")
    
    
def compute_viterbi_error(estimated_states, hidden_states):
    count = 0
    for i in range(0, len(hidden_states)):
        (estx, esty, act) = estimated_states[i]
        (hx, hy, acth) = hidden_states[i]
        if(estx == hx and esty == hy):
            count+=1
        else:
            print(i, hidden_states[i], estimated_states[i])
    print("Number of correct estimations by viterbi:")
    print(count)
    print("Total estimations:")
    print(len(hidden_states))
    print(" ")
        
    
    

def compute_observation_error(observations, hidden_states):
    count = 0
    for i in range(0, len(observations)):
        if(observations[i] != None):
            (obx, oby) = observations[i]
            (hx, hy, act) = hidden_states[i]
            if(obx == hx and oby == hy):
                count+=1
    print("Number of correct observations:")
    print(count)
    print("Total observations:")
    print(len(hidden_states))
    print(" ")



if __name__ == '__main__':
   
    enable_graphics = True
    
    missing_observations = True
    if missing_observations:
        filename = 'test_missing.txt'
    else:
        filename = 'test.txt'
            
    # load data    
    hidden_states, observations = rover.load_data(filename)
    num_time_steps = len(hidden_states)

    all_possible_hidden_states   = rover.get_all_hidden_states()
    all_possible_observed_states = rover.get_all_observed_states()
    prior_distribution           = rover.initial_distribution()
    
    print('Running forward-backward...')
    marginals = forward_backward(all_possible_hidden_states,
                                 all_possible_observed_states,
                                 prior_distribution,
                                 rover.transition_model,
                                 rover.observation_model,
                                 observations)
    print('\n')

    timestep = num_time_steps - 1
    
    print("Most likely parts of marginal at time %d:" % (timestep))
    print(sorted(marginals[timestep].items(), key=lambda x: x[1], reverse=True)[:10])
    print('\n')

    print("Most likely parts of marginal at time 30:")
    print(sorted(marginals[30].items(), key=lambda x: x[1], reverse=True)[:10])
    print('\n')
    
#    for i in range(0, len(marginals)):
#        print("max marginal at time %d:" %i)
#        print(sorted(marginals[i].items(), key=lambda x: x[1], reverse=True)[:1])
#        print(" ")

    print('Running Viterbi...')
    estimated_states = Viterbi(all_possible_hidden_states,
                               all_possible_observed_states,
                               prior_distribution,
                               rover.transition_model,
                               rover.observation_model,
                               observations)
    print('\n')
    
    print("Last 10 hidden states in the MAP estimate:")
    for time_step in range(num_time_steps - 10, num_time_steps):
        print(estimated_states[time_step])
        
    """ Compute error """
    compute_observation_error(observations, hidden_states)
    compute_viterbi_error(estimated_states, hidden_states)
    compute_forward_backward_error(marginals, hidden_states, all_possible_hidden_states)
  
    # if you haven't complete the algorithms, to use the visualization tool
    # let estimated_states = [None]*num_time_steps, marginals = [None]*num_time_steps
    # estimated_states = [None]*num_time_steps
    # marginals = [None]*num_time_steps
    if enable_graphics:
        app = graphics.playback_positions(hidden_states,
                                          observations,
                                          estimated_states,
                                          marginals)
        app.mainloop()
        
