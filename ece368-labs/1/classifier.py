import os.path
import numpy as np
import util
import math
import matplotlib.pyplot as plt

def learn_distributions(file_lists_by_category):
    """
    Estimate the parameters p_d, and q_d from the training set
    
    Input
    -----
    file_lists_by_category: A two-element list. The first element is a list of 
    spam files, and the second element is a list of ham files.

    Output
    ------
    probabilities_by_category: A two-element tuple. The first element is a dict 
    whose keys are words, and whose values are the smoothed estimates of p_d;
    the second element is a dict whose keys are words, and whose values are the 
    smoothed estimates of q_d 
    """
    spam_files = file_lists_by_category[0]
    ham_files = file_lists_by_category[1]
    
    ### W is the vocabulary, W = {w1, w2, ..., wd}, generate this by going through all the files
    print("Generating vocabulary...")
    W = dict();
    
    for x in spam_files:
        words = util.get_words_in_file(x)
        for w in words:
            W[w] = 1
    
    for x in ham_files:
        words = util.get_words_in_file(x)
        for w in words:
            W[w] = 1
    
    ### generate p_d dict and q_d dict, perform laplace smoothing
    print("Generating posterior probabilities...")
    p_d = dict()
    q_d = dict()
    laplace_smooth_word_count_spam = util.get_total_word_count(spam_files) + len(W)
    laplace_smooth_word_count_ham = util.get_total_word_count(ham_files) + len(W)
    
    wc_spam = dict()
    for f in spam_files:
        words = util.get_words_in_file(f)
        for w in words:
            if w in wc_spam:
                wc_spam[w] += 1
            else:
                wc_spam[w] = 1
            
    wc_ham = dict()
    for f in ham_files:
        words = util.get_words_in_file(f)
        for w in words:
            if w in wc_ham:
                wc_ham[w] += 1
            else:
                wc_ham[w] = 1
    
    for w in W:
        if w in wc_spam:
            p_d[w] = (wc_spam[w] + 1)/(laplace_smooth_word_count_spam)
        else:
            p_d[w] = 1/laplace_smooth_word_count_spam
            
        if w in wc_ham:
            q_d[w] = (wc_ham[w] + 1)/(laplace_smooth_word_count_ham)
        else:
            q_d[w] = 1/laplace_smooth_word_count_ham

    probabilities_by_category = [p_d, q_d]
    
    return probabilities_by_category


def classify_new_email(filename,probabilities_by_category,prior_by_category, zeta):
    """
    Use Naive Bayes classification to classify the email in the given file.

    Inputs
    ------
    filename: name of the file to be classified
    probabilities_by_category: output of function learn_distributions
    prior_by_category: A two-element list as [\pi, 1-\pi], where \pi is the 
    parameter in the prior class distribution

    Output
    ------
    classify_result: A two-element tuple. The first element is a string whose value
    is either 'spam' or 'ham' depending on the classification result, and the 
    second element is a two-element list as [log p(y=1|x), log p(y=0|x)], 
    representing the log posterior probabilities
    """
    ### Construct the feature vector x
    x = dict()
    words = util.get_words_in_file(filename)
    for w in words:
        if w in x:
            x[w] += 1
        else:
            x[w] = 1
    
    ### Calculate multinomial_coef = [(x1+x2+...xd)!]/[(x1!)(x2!)...(xd)!]
    numerator = 0
    for w in x:
        numerator += x[w]
    numerator = math.factorial(numerator)
    
    denominator = 1
    for w in x:
        denominator = denominator*math.factorial(x[w])  
    
    log_multinomial_coef = math.log10(numerator) - math.log10(denominator)
    
    ### Posterior of being spam: log[ p(y=1|x) ]= log[ p(x|y=1)*p(y=1) ]
    p_d = probabilities_by_category[0]
    log_of_product_spam = 0;
    
    for w in p_d:
        if w in x:
            log_of_product_spam += (x[w] * math.log10(p_d[w]))
        
    p_y1 = log_of_product_spam + log_multinomial_coef + math.log10(prior_by_category[0])
    
    ### Posterior of being spam: log[ p(y=0|x) ]= log[ p(x|y=0)*p(y=0) ]  
    q_d = probabilities_by_category[1]  
    log_of_product_ham = 0;
    
    for w in q_d:
        if w in x:
            log_of_product_ham += (x[w] * math.log10(q_d[w]))
        
    p_y0 = log_of_product_ham + log_multinomial_coef + math.log10(prior_by_category[1])

    if(p_y1 >= zeta*p_y0):
        classify_result = ("spam", [p_y1, p_y0])
    else:
        classify_result = ("ham", [p_y1, p_y0])
    
    return classify_result


if __name__ == '__main__':
    
    # folder for training and testing 
    spam_folder = "data/spam"
    ham_folder = "data/ham"
    test_folder = "data/testing"

    # generate the file lists for training
    print("Training...")
    file_lists = []
    for folder in (spam_folder, ham_folder):
        file_lists.append(util.get_files_in_folder(folder))
        
    # Learn the distributions    
    probabilities_by_category = learn_distributions(file_lists)
    
    # prior class distribution
    priors_by_category = [0.5, 0.5]
    
    # Store the classification results
    performance_measures = np.zeros([2,2])
    # explanation of performance_measures:
    # columns and rows are indexed by 0 = 'spam' and 1 = 'ham'
    # rows correspond to true label, columns correspond to guessed label
    # to be more clear, performance_measures = [[p1 p2]
    #                                           [p3 p4]]
    # p1 = Number of emails whose true label is 'spam' and classified as 'spam' 
    # p2 = Number of emails whose true label is 'spam' and classified as 'ham' 
    # p3 = Number of emails whose true label is 'ham' and classified as 'spam' 
    # p4 = Number of emails whose true label is 'ham' and classified as 'ham' 

    # Classify emails from testing set and measure the performance
    print("Classifying...")
    for filename in (util.get_files_in_folder(test_folder)):
        # Classify
        label,log_posterior = classify_new_email(filename,
                                                 probabilities_by_category,
                                                 priors_by_category, 1)
        
        # Measure performance (the filename indicates the true label)
        base = os.path.basename(filename)
        true_index = ('ham' in base) 
        guessed_index = (label == 'ham')
        performance_measures[int(true_index), int(guessed_index)] += 1

    template="You correctly classified %d out of %d spam emails, and %d out of %d ham emails."
    # Correct counts are on the diagonal
    correct = np.diag(performance_measures)
    # totals are obtained by summing across guessed labels
    totals = np.sum(performance_measures, 1)
    print(template % (correct[0],totals[0],correct[1],totals[1]))
    
    
    ### TODO: Write your code here to modify the decision rule such that
    ### Type 1 and Type 2 errors can be traded off, plot the trade-off curve
    plt.figure(1)
    
    zeta = np.arange(0.6, 1.25, 0.05)
    for i in range(0, len(zeta)):
        performance_measures = np.zeros([2,2])
        for filename in (util.get_files_in_folder(test_folder)):
            # Classify
            label,log_posterior = classify_new_email(filename,
                                                 probabilities_by_category,
                                                 priors_by_category, zeta[i])
        
            # Measure performance (the filename indicates the true label)
            base = os.path.basename(filename)
            true_index = ('ham' in base) 
            guessed_index = (label == 'ham')
            performance_measures[int(true_index), int(guessed_index)] += 1
        plt.scatter(performance_measures[0][1], performance_measures[1][0], color='blue')
    
    plt.xlabel('Type 1 Errors')
    plt.ylabel('Type 2 Errors')
    
    plt.savefig("nbc.pdf")
    plt.show()
 