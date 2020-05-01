import numpy as np

def density_Gaussian(mean_vec,covariance_mat,x_set):
    """ Return the density of multivariate Gaussian distribution
        Inputs: 
            mean_vec is a 1D array (like array([,,,]))
            covariance_mat is a 2D array (like array([[,],[,]]))
            x_set is a 2D array, each row is a sample
        Output:
            a 1D array, probability density evaluated at the samples in x_set.
    """
    d = x_set.shape[1]  
    inv_Sigma = np.linalg.inv(covariance_mat)
    det_Sigma = np.linalg.det(covariance_mat)
    density = []
    for x in x_set:
        x_minus_mu = x - mean_vec
        exponent = - 0.5*np.dot(np.dot(x_minus_mu,inv_Sigma),x_minus_mu.T)
        prob = 1/(((2*np.pi) ** (d/2))*np.sqrt(det_Sigma))*np.exp(exponent)
        density.append(prob)
    density_array = np.array(density)  
    
    return density_array 

def get_data_in_file(filename):
    """ 
    Read the input/traget data from the given file as arrays 
    """
    with open(filename, 'r') as f:
        data = []
        # read the data line by line
        for line in f: 
            data.append([float(x) for x in line.split()]) 
            
    # store the inputs in x and the tragets in z      
    data_array = np.array(data)     
    x = data_array[:,0:1]   # 2D array
    z = data_array[:,1:2]   # 2D array
    
    return (x, z)    


def density_Gaussian_Plot(mean_vec,covariance_mat,samples):
    """ 
        Similar to the above function but better. Instead of returning a 1D array, 
        return a 2D np array that can be plugged right into the plt.contour function.
        
        Return the density of multivariate Gaussian distribution
        Inputs: 
            mean_vec is a 1D array (like array([,,,]))
            covariance_mat is a 2D array (like array([[,],[,]]))
            x_set is a 2D array of samples. Think of it like a meshgrid.
        Output:
            a 2D array of samples, probability density evaluated at the samples in x_set.
    """
    ''' Declare an array with the same dimensions as samples '''
    inv_Sigma = np.linalg.inv(covariance_mat)
    det_Sigma = np.linalg.det(covariance_mat)
    d = len(samples[0][0])
    
    num_rows = len(samples)
    num_cols = len(samples[0])
    Z_plot = np.zeros([num_rows, num_cols])
    
    for i in range(0, num_rows):
        for j in range(0, num_cols):
            x_minus_mu = samples[i][j] - mean_vec
            exponent = - 0.5*np.dot(np.dot(x_minus_mu,inv_Sigma),x_minus_mu.T)
            prob = 1/(((2*np.pi) ** (d/2))*np.sqrt(det_Sigma))*np.exp(exponent)
            Z_plot[j][i] = prob
            
    return Z_plot

# def density_Gaussian_Plot_Posterior(mu, cov, samples, )
