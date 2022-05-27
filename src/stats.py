import pandas as pd
import glob

def processfile(fname):
    df=pd.read_csv(fname,delim_whitespace=True)
    #print(df)
    mean = df['file'].mean()
    max1 = df['file'].max()
    min1 = df['file'].min()

    print("FILE: "+fname+" Mean: " +str(mean)+" MAX: "+str(max1) + " MIN: " + str(min1))


if __name__ == "__main__":
    dirname="./res"
    files=glob.glob("./res/round3/*-Processed*")
    print(files)
    for filename in files:
        processfile(filename)
