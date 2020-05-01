import numpy as np
import matplotlib.pyplot as plt
import util

def priorDistribution(beta):
    """
    Plot the contours of the prior distribution p(a)
    
    Inputs:
    ------
    beta: hyperparameter in the proir distribution
    
    Outputs: None, except a contour plot.
    In each contour plot, x axis represents a0 and y axis represents a1.
    -----
    """
    plt.figure(1)
    
    mu = np.array([0.0, 0.0])
    cov = np.matrix([[beta, 0.0], 
                     [0.0, beta]])
    
    a0 = np.arange(-1, 1, 0.02)
    a1 = np.arange(-1, 1, 0.02)
    A0, A1 = np.meshgrid(a0, a1)
    
    samples = np.zeros([len(a0), len(a1), 2])
    
    for i in range(0, len(a0)):
        for j in range(0, len(a1)):
            samples[i][j] = [a0[i], a1[j]]
            
    Z_plot = util.density_Gaussian_Plot(mu, cov, samples)
    
    """ Plot the distribution """
    plt.scatter(-0.1, -0.5, color='blue') 
    plt.contour(A0, A1, Z_plot)
    plt.title("Prior distribution of a0 and a1")
    plt.xlabel("a0")
    plt.ylabel("a1")
    plt.savefig("prior.pdf")
    plt.show()
     
    return 
    


def posteriorDistribution(x,z,beta,sigma2):
    """
    Plot the contours of the posterior distribution p(a|x,z)
    
    Inputs:
    ------
    x: inputs from training set
    z: targets from training set
    beta: hyperparameter in the proir distribution
    sigma2: variance of Gaussian noise
    
    Outputs: 
    -----
    mu: mean of the posterior distribution p(a|x,z)
    Cov: covariance of the posterior distribution p(a|x,z)
    """

    """ Calculate the mean and covariace of the posterior distributions """
    X_matrix = np.zeros([len(x), 2])
    for i in range(0, len(x)):
        X_matrix[i] = [1, x[i]]
    
    temp_matrix = np.asmatrix( np.matmul(X_matrix.T, X_matrix) + (sigma2/beta)*np.identity(2))
    mu = temp_matrix.I * X_matrix.T * np.asmatrix(z)
    
    temp_matrix = np.asmatrix(np.matmul(X_matrix.T, X_matrix) + (sigma2/beta)*np.identity(2))
    Cov = temp_matrix.I * sigma2
    
    
    """ Plot using Gaussian """
    plt.figure(2)
    
    a0 = np.arange(-1, 1, 0.005)
    a1 = np.arange(-1, 1, 0.005)
    A0, A1 = np.meshgrid(a0, a1)
    
    samples = np.zeros([len(a1), len(a0), 2])
    
    for i in range(0, len(a0)):
        for j in range(0, len(a1)):
            samples[i][j] = [a0[i], a1[j]]
    
    Z_plot = util.density_Gaussian_Plot(mu.T, Cov, samples)  
    
    plt.scatter(-0.1, -0.5, color='blue')  
    plt.contour(A0, A1, Z_plot)
    plt.title("Posterior distribution of a0 and a1")
    plt.xlabel("a0")
    plt.ylabel("a1")
    plt.savefig("posterior1.pdf")
    plt.show()    
    
    return (mu,Cov)


def predictionDistribution(x,beta,sigma2,mu,Cov,x_train,z_train):
    """
    Make predictions for the inputs in x, and plot the predicted results 
    
    Inputs:
    ------
    x: new inputs
    beta: hyperparameter in the proir distribution
    sigma2: variance of Gaussian noise
    mu: output of posteriorDistribution()
    Cov: output of posteriorDistribution()
    x_train,z_train: training samples, used for scatter plot
    
    Outputs: None
    -----
    """
    
    """ Plot scatter plot of training set """
    plt.figure(3)
    
    for i in range(0, len(x_train)):
        plt.scatter(x_train[i], z_train[i], color='red')
    
    for i in range(0, len(x)):
        x_new = np.asmatrix([[1],
                             [x[i]]])
        pred_mean = np.matmul(mu.T, x_new)
        pred_err = np.matmul( np.matmul(x_new.T, Cov), x_new) + sigma2
        err = np.sqrt(pred_err)
        plt.errorbar(x[i], pred_mean, yerr=err, color='blue')
    
    plt.title("Prediction")
    plt.xlabel("x")
    plt.xlim(-4, 4)
    plt.ylabel("z")
    plt.ylim(-4, 4)
    plt.savefig("predict1.pdf")
    plt.show
    
    return 


if __name__ == '__main__':
    
    # training data
    x_train, z_train = util.get_data_in_file('training.txt')
    # new inputs for prediction 
    x_test = [x for x in np.arange(-4,4.01,0.2)]
    
    # known parameters 
    sigma2 = 0.1
    beta = 1
    
    # number of training samples used to compute posterior
    ns  =  1
    
    # used samples
    x = x_train[0:ns]
    z = z_train[0:ns]
    
    # prior distribution p(a)
    priorDistribution(beta)
    
    # posterior distribution p(a|x,z)
    mu, Cov = posteriorDistribution(x,z,beta,sigma2)
    
    # distribution of the prediction
    predictionDistribution(x_test,beta,sigma2,mu,Cov,x,z)
    

   

    
    
    

    
