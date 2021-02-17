import pandas as pd
import matplotlib.pyplot as plt

def buildGraph(df,filename,xSeriesName,ySeriesName):
    df[[xSeriesName,ySeriesName]].plot(title="Tokyo")
    plt.savefig(filename)
