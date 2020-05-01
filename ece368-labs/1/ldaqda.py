import numpy as np
import matplotlib.pyplot as plt
import math
import utilpt2

def lda_boundary_plot_helper(mu_male, mu_female, cov, data):
    pi = 0.5
    male_lda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov) ) ) - (1/2) * ((data - mu_male) * (np.linalg.inv(cov)) * (data - mu_male).reshape(2,1))
    female_lda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov) ) ) - (1/2) * ((data - mu_female) * (np.linalg.inv(cov)) * (data - mu_female).reshape(2,1))
    difference = male_lda_map - female_lda_map
    return 1/difference      

def qda_boundary_plot_helper(mu_male, mu_female, cov_male, cov_female, data):
    pi = 0.5
    male_qda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov_male) ) ) - (1/2) * ((data - mu_male) * (np.linalg.inv(cov_male)) * (data - mu_male).reshape(2,1))
    female_qda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov_female) ) ) - (1/2) * ((data - mu_female) * (np.linalg.inv(cov_female)) * (data - mu_female).reshape(2,1))
    difference = male_qda_map - female_qda_map
    return 1/difference

def classify_with_height_and_weight(mu_male,mu_female,cov,cov_male,cov_female,data):
    """
    Using height and weight data, make a classification
    Returns a tuple. First enttry describes classification for lda and the other describes classification for qda
    """
    # lda
    lda = 0.0
    pi = 0.5
    male_lda_map = 0.0
    female_lda_map = 0.0
    
    male_lda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov) ) ) - (1/2) * ((data - mu_male) * (np.linalg.inv(cov)) * (data - mu_male).reshape(2,1))
    female_lda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov) ) ) - (1/2) * ((data - mu_female) * (np.linalg.inv(cov)) * (data - mu_female).reshape(2,1))
    
    if(male_lda_map >= female_lda_map):
        lda = 1
    else:
        lda = 2
    
    #qda
    qda = 0.0
    male_qda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov_male) ) ) - (1/2) * ((data - mu_male) * (np.linalg.inv(cov_male)) * (data - mu_male).reshape(2,1))
    female_qda_map = math.log(pi) - math.log( math.sqrt( np.linalg.norm(cov_female) ) ) - (1/2) * ((data - mu_female) * (np.linalg.inv(cov_female)) * (data - mu_female).reshape(2,1))
    
    if(male_qda_map >= female_qda_map):
        qda = 1
    else:
        qda = 2
    
    return (lda, qda)


def discrimAnalysis(x, y):
    """
    Estimate the parameters in LDA/QDA and visualize the LDA/QDA models
    
    Inputs
    ------
    x: a N-by-2 2D array contains the height/weight data of the N samples
    
    y: a N-by-1 1D array contains the labels of the N samples 
    
    Outputs
    -----
    A tuple of five elments: mu_male,mu_female,cov,cov_male,cov_female
    in which mu_male, mu_female are mean vectors (as 1D arrays)
             cov, cov_male, cov_female are covariance matrices (as 2D arrays)
    Besides producing the five outputs, you need also to plot 1 figure for LDA 
    and 1 figure for QDA in this function         
    """
    #######################################
    ### Calculate mu_male and mu_female ###
    #######################################
    N = len(y)
    mu = np.array([0.0, 0.0])
    mu_male = np.array([0.0, 0.0])
    mu_female = np.array([0.0, 0.0])
    total_male = 0
    total_female = 0
    
    for i in range(0,N):
        mu[0] += x[i][0]
        mu[1] += x[i][1]
        if(y[i] == 1):
            mu_male[0] += x[i][0]
            mu_male[1] += x[i][1]
            total_male += 1
        if(y[i] == 2):
            mu_female[0] += x[i][0]
            mu_female[1] += x[i][1]
            total_female += 1
    
    mu = (1/N) * mu
    mu_male = (1/total_male) * mu_male
    mu_female = (1/total_female) * mu_female
    
    
    ###############################################
    ### Calculate cov, cov_male, and cov_female ###
    ###############################################
    cov = np.matrix([[0.0, 0.0], [0.0, 0.0]])
    cov_male = np.matrix([[0.0, 0.0], [0.0, 0.0]])
    cov_female = np.matrix([[0.0, 0.0], [0.0, 0.0]])
    
    for i in range(0,N):
        cov += (x[i] - mu) * (x[i] - mu).reshape(2,1)
        if(y[i] == 1):
            cov_male += (x[i] - mu_male) * (x[i] - mu_male).reshape(2,1)
        if(y[i] == 2): 
            cov_female += (x[i] - mu_female) * (x[i] - mu_female).reshape(2,1)
    
    cov = (1/N) * cov
    cov_male = (1/total_male) * cov_male
    cov_female = (1/total_female) * cov_female
    
    ##################################
    ### Print Mean and Covariances ###
    ##################################
    print("Mean Vectors:")
    print(mu)
    print(mu_male)
    print(mu_female)
    print("\n")
    
    print("Covariance matricies:")
    print(cov)
    print(cov_male)
    print(cov_female)
    print("\n")
    
    
    #######################################
    ### Produce figures for LDA and QDA ###
    #######################################
    """
    x_set_male = []
    x_set_female = []
    for i in range(0,N):
        if(y[i] == 1):
            x_set_male.append([x[0], x[1]])
        else:
            x_set_female.append([x[0], x[1]])
    """
    
    # Mesh grid declaration
    height = np.arange(50, 80, 0.1)
    weight = np.arange(80, 280, 0.1)
    H, W = np.meshgrid(height, weight)

    # x_set declaration    
    x_set = []
    for i in range(0, len(height) ):
        for j in range(0, len(weight) ):
            x_set.append([height[i], weight[j]])
    x_set_array = np.array(x_set)      

    #########################
    ### Plot LDA: ########### 
    plt.figure(1)       
    
    density_array_lda_male = utilpt2.density_Gaussian(mu_male, cov, x_set_array)
    density_array_lda_female = utilpt2.density_Gaussian(mu_female, cov, x_set_array)
    
    Z_lda_male = np.zeros([len(weight), len(height)])
    for row in range(0 , len(weight)):
        for col in range(0, len(height)):
            Z_lda_male[row][col] = density_array_lda_male[col*len(weight) + row]
    
    Z_lda_female = np.zeros([len(weight), len(height)])
    for row in range(0 , len(weight)):
        for col in range(0, len(height)):
            Z_lda_female[row][col] = density_array_lda_female[col*len(weight) + row]
    
    plt.contour(H, W, Z_lda_male)
    plt.contour(H, W, Z_lda_female)
    
    # Plot boundary:
    B_lda = np.zeros([len(weight), len(height)])
    for row in range(0 , len(weight)):
        for col in range(0, len(height)):
            B_lda[row][col] = lda_boundary_plot_helper(mu_male, mu_female, cov, (height[col], weight[row]) )    
    plt.contour(H, W, B_lda)
    
    # Scatter plot of data points
    for i in range(0, N):
        if(y[i] == 1):
            plt.scatter(x[i][0], x[i][1], color = 'blue')
        else:
            plt.scatter(x[i][0], x[i][1], color = 'red')
    
    plt.xlabel('height')
    plt.ylabel('weight')    
    plt.savefig("lda.pdf")
    plt.show()

    #############################
    ### Plot QDA: ###############
    plt.figure(2)
        
    density_array_qda_male = utilpt2.density_Gaussian(mu_male, cov_male, x_set_array)
    density_array_qda_female = utilpt2.density_Gaussian(mu_female, cov_female, x_set_array)
    
    Z_qda_male = np.zeros([len(weight), len(height)])
    for row in range(0 , len(weight)):
        for col in range(0, len(height)):
            Z_qda_male[row][col] = density_array_qda_male[col*len(weight) + row]
    
    Z_qda_female = np.zeros([len(weight), len(height)])
    for row in range(0 , len(weight)):
        for col in range(0, len(height)):
            Z_qda_female[row][col] = density_array_qda_female[col*len(weight) + row]
    
    plt.contour(H, W, Z_qda_male)
    plt.contour(H, W, Z_qda_female)
    
    # Plot boundary:
    B_qda = np.zeros([len(weight), len(height)])
    for row in range(0 , len(weight)):
        for col in range(0, len(height)):
            B_qda[row][col] = qda_boundary_plot_helper(mu_male, mu_female, cov_male, cov_female, (height[col], weight[row]) )
    
    plt.contour(H, W, B_qda)
    
    # Scatter plot of data points
    for i in range(0, N):
        if(y[i] == 1):
            plt.scatter(x[i][0], x[i][1], color = 'blue')
        else:
            plt.scatter(x[i][0], x[i][1], color = 'red')
    
    plt.xlabel('height')
    plt.ylabel('weight')
    plt.savefig("qda.pdf")
    plt.show()
    
    return (mu_male,mu_female,cov,cov_male,cov_female)
    

def misRate(mu_male,mu_female,cov,cov_male,cov_female,x,y):
    """
    Use LDA/QDA on the testing set and compute the misclassification rate
    
    Inputs
    ------
    mu_male,mu_female,cov,cov_male,mu_female: parameters from discrimAnalysis
    
    x: a N-by-2 2D array contains the height/weight data of the N samples  
    
    y: a N-by-1 1D array contains the labels of the N samples 
    
    Outputs
    -----
    A tuple of two elements: (mis rate in LDA, mis rate in QDA )
    """
    ### mis_lda calculation
    N = len(y)
    lda = []
    qda = []
    
    for i in range(0,N):
        lda_pred, qda_pred= classify_with_height_and_weight(mu_male,mu_female,cov,cov_male,cov_female,x[i])
        lda.append(lda_pred)
        qda.append(qda_pred)
    
    mis_lda = 0.0
    mis_qda = 0.0
    
    for i in range(0,N):
        if(not lda[i] == y[i]):
            mis_lda += 1
        if(not qda[i] == y[i]):
            mis_qda += 1
    
    mis_lda = mis_lda/N
    mis_qda = mis_qda/N
    
    print("Miss rate for lda: " + str(mis_lda))
    print("Miss rate for qda: " + str(mis_qda))
    
    return (mis_lda, mis_qda)


if __name__ == '__main__':
    
    # load training data and testing data
    x_train, y_train = utilpt2.get_data_in_file('trainHeightWeight.txt')
    x_test, y_test = utilpt2.get_data_in_file('testHeightWeight.txt')
    
    # parameter estimation and visualization in LDA/QDA
    mu_male,mu_female,cov,cov_male,cov_female = discrimAnalysis(x_train,y_train)
    
    # misclassification rate computation
    mis_LDA,mis_QDA = misRate(mu_male,mu_female,cov,cov_male,cov_female,x_test,y_test)
    
    
    

    
