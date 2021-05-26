from os import sep
import pandas as pd

def main():
    data = pd.read_table(snakemake.input[0], header=None)
    data.columns = ['a','b','c','d']
    data['f'] = round(data['c'] / (data['b']/1000),3)
    data.to_csv(snakemake.output[0],sep="\t",header=None)

if __name__ == "__main__":
	main()