import os

def get_words_in_file(filename):
    """ Returns a list of all words in the file at filename. """
    with open(filename, 'r', encoding = "ISO-8859-1") as f:
        # read() reads in a string from a file pointer, and split() splits a
        # string into words based on whitespace
        words = f.read().split()
    return words

def get_files_in_folder(folder):
    """ Returns a list of files in folder (including the path to the file) """
    filenames = os.listdir(folder)
    # os.path.join combines paths while dealing with /s and \s appropriately
    full_filenames = [os.path.join(folder, filename) for filename in filenames]
    return full_filenames

def get_counts(file_list):
    """ 
    Returns a dict whose keys are words and whose values are the number of 
    files in file_list the key occurred in. 
    """
    counts = Counter()
    for f in file_list:
        words = get_words_in_file(f)
        for w in set(words):
            counts[w] += 1
    return counts

def get_word_freq(file_list):
    """ 
    Returns a dict whose keys are words and whose values are word freq
    """
    counts = Counter()
    for f in file_list:
        words = get_words_in_file(f)
        for w in words:
            counts[w] += 1
    return counts

def exists_in_list(word_list, word):
    """
    Returns true if word exists in the list, returns false if doesnt
    """
    for w in word_list:
        if(w == word):
            return True
    return False

def word_count_in_file_list(file_list, key_word):
    """
    Returns how many times a word comes up in a list of files
    """
    count = 0
    for f in file_list:
        words = get_words_in_file(f)
        for w in words:
            if(w == key_word):
                count += 1  
    return count

def get_total_word_count(file_list):
    """
    Returns total number of words in a list of files
    """
    count = 0
    for f in file_list:
        words = get_words_in_file(f)
        for w in words:
            count += 1
    return count

class Counter(dict):
    """
    Like a dict, but returns 0 if the key isn't found.
    """
    def __missing__(self, key):
        return 0
    
def get_data_in_file(filename):
    """
    Gets the data in the file and returns a tuple with two elements
    First element is a Nx2 matrix x, where x[n][0] is height of nth person and x[n][1] is the weight of nth person 
    Second element is a N long vector y of labels, either 1 or 2
    """
    x = []
    y = []
    with open(filename) as f:
        for line in f:
            entry = line.split()
            x.append([float(entry[2]), float(entry[1])])
            y.append(float(entry[0]))
    
    return (x, y)
